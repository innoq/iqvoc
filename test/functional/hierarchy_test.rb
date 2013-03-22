# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class HierarchyTest < ActionController::TestCase

  setup do
    @controller = HierarchyController.new

    # create a concept hierarchy
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :root rdf:type skos:Concept
      :root skos:prefLabel "Root"@en
      :root iqvoc:publishedAt "#{Time.now}"^^<DateTime>
      :root skos:topConceptOf :scheme

      :foo rdf:type skos:Concept
      :foo skos:prefLabel "Foo"@en
      :foo iqvoc:publishedAt "#{Time.now}"^^<DateTime>
      :foo skos:broader :root

      :bar rdf:type skos:Concept
      :bar skos:prefLabel "Bar"@en
      :bar iqvoc:publishedAt "#{Time.now}"^^<DateTime>
      :bar skos:broader :root

      :alpha rdf:type skos:Concept
      :alpha skos:prefLabel "Alpha"@en
      :alpha iqvoc:publishedAt "#{Time.now}"^^<DateTime>
      :alpha skos:broader :bar

      :bravo rdf:type skos:Concept
      :bravo skos:prefLabel "Bravo"@en
      :bravo iqvoc:publishedAt "#{Time.now}"^^<DateTime>
      :bravo skos:broader :bar

      :uno rdf:type skos:Concept
      :uno skos:prefLabel "Uno"@en
      :uno iqvoc:publishedAt "#{Time.now}"^^<DateTime>
      :uno skos:broader :bravo

      :dos rdf:type skos:Concept
      :dos skos:prefLabel "Dos"@en
      :dos iqvoc:publishedAt "#{Time.now}"^^<DateTime>
      :dos skos:broader :bravo

      :lorem rdf:type skos:Concept
      :lorem skos:prefLabel "Lorem"@en
      :lorem iqvoc:publishedAt "#{Time.now}"^^<DateTime>
      :lorem skos:broader :dos

      :ipsum rdf:type skos:Concept
      :ipsum skos:prefLabel "Ipsum"@en
      :ipsum iqvoc:publishedAt "#{Time.now}"^^<DateTime>
      :ipsum skos:broader :dos
    EOT
  end

  test 'caching' do
    params = { :lang => 'en', :format => 'ttl', :root => 'root' }

    # ETag generation & cache control

    get :show, params
    etag = @response.headers['ETag']
    assert_response 200
    assert etag
    assert @response.headers['Cache-Control'].include?('public')

    get :show, params
    assert_response 200
    assert_equal etag, @response.headers['ETag']

    get :show, params.merge(:published => '0')
    assert_response 200
    assert @response.headers['Cache-Control'].include?('private')

    # ETag keyed on params

    get :show, params.merge(:depth => 4)
    assert_response 200
    assert_not_equal etag, @response.headers['ETag']

    get :show, params.merge(:published => 0)
    assert_response 200
    assert_not_equal etag, @response.headers['ETag']

    # ETag keyed on (any in-scope) concept modification

    t0 = Time.now
    t1 = Time.now + 30

    Iqvoc::RDFAPI.parse_triples <<-EOT
      :dummy rdf:type skos:Concept
      :dummy skos:prefLabel "Dummy"@en
    EOT

    dummy = Iqvoc::RDFAPI.cached(:dummy)
    dummy.update_attribute('updated_at', t1)
    get :show, params
    assert_response 200
    assert_equal etag, @response.headers['ETag']

    dummy.update_attribute('published_at', t0)
    dummy.update_attribute('updated_at', t1)
    get :show, params
    assert_response 200
    new_etag = @response.headers['ETag']
    assert_not_equal etag, new_etag

    # conditional caching

    @request.env['HTTP_IF_NONE_MATCH'] = new_etag
    get :show, params
    assert_response 304
    assert_equal 0, @response.body.strip.length

    @request.env['HTTP_IF_NONE_MATCH'] = 'dummy'
    get :show, params
    assert_response 200
  end

  test 'unsupported content type' do
    get :show, :lang => 'en', :format => 'N/A', :root => 'root'
    assert_response 406
  end

  test 'RDF representations' do
    # Turtle

    get :show, :lang => 'en', :format => 'ttl', :root => 'root'
    assert_response 200
    assert_equal @response.content_type, 'text/turtle'
    assert @response.body.include?(<<-EOS)
:root a skos:Concept;
      skos:topConceptOf :scheme;
      skos:prefLabel "Root"@en;
      skos:narrower :foo;
      skos:narrower :bar.
    EOS
    assert @response.body.include?(<<-EOS)
:foo a skos:Concept;
     skos:prefLabel "Foo"@en.
    EOS
    assert @response.body.include?(<<-EOS)
:bar a skos:Concept;
     skos:prefLabel "Bar"@en;
     skos:narrower :alpha;
     skos:narrower :bravo.
    EOS
    assert @response.body.include?(<<-EOS)
:alpha a skos:Concept;
       skos:prefLabel "Alpha"@en.
    EOS
    assert @response.body.include?(<<-EOS)
:bravo a skos:Concept;
       skos:prefLabel "Bravo"@en;
       skos:narrower :uno;
       skos:narrower :dos.
    EOS
    assert @response.body.include?(<<-EOS)
:uno a skos:Concept;
     skos:prefLabel "Uno"@en.
    EOS
    assert @response.body.include?(<<-EOS)
:dos a skos:Concept;
     skos:prefLabel "Dos"@en.
    EOS

    get :show, :lang => 'en', :format => 'ttl', :root => 'lorem', :dir => 'up'
    assert_response 200
    assert_equal @response.content_type, 'text/turtle'
    assert @response.body.include?(<<-EOS)
:lorem a skos:Concept;
       skos:prefLabel "Lorem"@en;
       skos:broader :dos.
    EOS
    assert @response.body.include?(<<-EOS)
:dos a skos:Concept;
     skos:prefLabel "Dos"@en;
     skos:broader :bravo.
    EOS
    assert @response.body.include?(<<-EOS)
:bravo a skos:Concept;
       skos:prefLabel "Bravo"@en;
       skos:broader :bar.
    EOS
    assert @response.body.include?(<<-EOS)
:bar a skos:Concept;
     skos:prefLabel "Bar"@en.
    EOS

    # RDF/XML

    get :show, :lang => 'en', :format => 'rdf', :root => 'root'
    assert_response 200
    assert_equal @response.content_type, 'application/xml+rdf'
  end

  test 'root parameter handling' do
    assert_raises(ActionController::RoutingError) do
      get :show, :format => 'html'
    end

    get :show, :lang => 'en', :format => 'html', :root => 'N/A'
    assert_response 404
    assert_equal 'no concept matching root parameter', flash[:error]
    entries = css_select('ul.concept-hierarchy li')
    assert_equal 0, entries.length

    get :show, :lang => 'en', :format => 'html', :root => 'root'
    assert_response 200
    assert_nil flash[:error]
    entries = get_entries('ul.concept-hierarchy li')
    assert_equal 1, entries.length
    assert_equal 'Root', entries[0]

    get :show, :lang => 'en', :format => 'html', :root => 'root'
    entries = get_entries('ul.concept-hierarchy li')
    assert_equal entries, ['Root']
    entries = get_entries('ul.concept-hierarchy li li')
    assert_equal entries, ['Foo', 'Bar']
    entries = get_entries('ul.concept-hierarchy li li li')
    assert_equal entries, ['Alpha', 'Bravo']
    entries = get_entries('ul.concept-hierarchy li li li li')
    assert_equal entries, ['Uno', 'Dos']
    entries = css_select('ul.concept-hierarchy li li li li li')
    assert_equal 0, entries.length # exceeded default depth

    get :show, :lang => 'en', :format => 'html', :root => 'bravo'
    entries = get_entries('ul.concept-hierarchy li')
    assert_equal entries, ['Bravo']
    entries = get_entries('ul.concept-hierarchy li li')
    assert_equal entries, ['Uno', 'Dos']
    entries = get_entries('ul.concept-hierarchy li li li')
    assert_equal entries, ['Lorem', 'Ipsum']
    entries = css_select('ul.concept-hierarchy li li li li')
    assert_equal 0, entries.length

    get :show, :lang => 'en', :format => 'html', :root => 'lorem'
    entries = get_entries('ul.concept-hierarchy li')
    assert_equal entries, ['Lorem']
    entries = css_select('ul.concept-hierarchy li li')
    assert_equal 0, entries.length
  end

  test 'depth handling' do
    selector = 'ul.concept-hierarchy li li li li li'

    get :show, :lang => 'en', :format => 'html', :root => 'root'
    entries = css_select(selector)
    assert_equal 0, entries.length # default depth is 3

    get :show, :lang => 'en', :format => 'html', :root => 'root', :depth => 4
    entries = css_select(selector)
    assert_equal 2, entries.length

    get :show, :lang => 'en', :format => 'html', :root => 'root', :depth => 1
    entries = get_entries('ul.concept-hierarchy li')
    assert_equal ['Root'], entries
    entries = get_entries('ul.concept-hierarchy li li')
    assert_equal ['Foo', 'Bar'], entries
    entries = css_select('ul.concept-hierarchy li li li')
    assert_equal 0, entries.length

    get :show, :lang => 'en', :format => 'html', :root => 'root', :depth => 'invalid'
    assert_response 400
    assert_equal flash[:error], 'invalid depth parameter'
  end

  test 'direction handling' do
    get :show, :lang => 'en', :format => 'html', :root => 'root'
    entries = get_entries('ul.concept-hierarchy li')
    assert_equal ['Root'], entries
    entries = get_entries('ul.concept-hierarchy li li li li')
    assert_equal ['Uno', 'Dos'], entries

    get :show, :lang => 'en', :format => 'html', :root => 'root', :dir => 'up'
    entries = get_entries('ul.concept-hierarchy li')
    assert_equal ['Root'], entries
    entries = css_select('ul.concept-hierarchy li li')
    assert_equal 0, entries.length

    get :show, :lang => 'en', :format => 'html', :root => 'lorem'
    entries = get_entries('ul.concept-hierarchy li')
    assert_equal ['Lorem'], entries
    entries = css_select('ul.concept-hierarchy li li')
    assert_equal 0, entries.length

    get :show, :lang => 'en', :format => 'html', :root => 'lorem', :dir => 'up'
    entries = get_entries('ul.concept-hierarchy li')
    assert_equal ['Lorem'], entries
    entries = get_entries('ul.concept-hierarchy li li li li')
    assert_equal ['Bar'], entries
    entries = css_select('ul.concept-hierarchy li li li li li')
    assert_equal 0, entries.length

    get :show, :lang => 'en', :format => 'html', :root => 'lorem', :dir => 'up', :depth => 4
    page.all('ul.concept-hierarchy li').
        map { |node| node.native.children.first.text }
    entries = get_entries('ul.concept-hierarchy li li li li li')
    assert_equal entries, ['Root']
  end

  test 'siblings handling' do
    get :show, :lang => 'en', :format => 'html', :root => 'foo'
    entries = get_all_entries('ul.concept-hierarchy li')
    assert_equal ['Foo'], entries

    get :show, :lang => 'en', :format => 'html', :root => 'foo', :siblings => true
    entries = get_all_entries('ul.concept-hierarchy li')
    assert_equal ['Foo', 'Bar'], entries

    get :show, :lang => 'en', :format => 'html', :root => 'lorem'
    entries = get_all_entries('ul.concept-hierarchy li')
    assert_equal ['Lorem'], entries

    get :show, :lang => 'en', :format => 'html', :root => 'lorem', :dir => 'up',
        :siblings => true
    entries = get_all_entries('ul.concept-hierarchy li')
    assert_equal 8, entries.length
    %w(Lorem Ipsum Uno Dos Alpha Bravo Bar Foo).each do |name|
      assert entries.include?(name), "missing entry: #{name}"
    end

    get :show, :lang => 'en', :format => 'html', :root => 'lorem', :dir => 'up',
        :siblings => true, :depth => 4
    entries = get_all_entries('ul.concept-hierarchy li')
    assert_equal 9, entries.length
    %w(Lorem Ipsum Uno Dos Alpha Bravo Bar Foo Root).each do |name|
      assert entries.include?(name), "missing entry: #{name}"
    end
  end

  def get_all_entries(selector)
    return page.all(selector).map { |node| node.native.children.first.text }
  end

  def get_entries(selector)
    return css_select(selector).map { |node| node.children.first.content }
  end

  def page # XXX: should not be necessary!?
    return Capybara::Node::Simple.new(@response.body)
  end

end
