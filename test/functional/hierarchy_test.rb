# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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
    concepts = YAML.load <<-EOS
root:
  foo:
  bar:
    alpha:
    bravo:
      uno:
      dos:
        lorem:
        ipsum:
    EOS
    @rel_class = Iqvoc::Concept.broader_relation_class.narrower_class
    @concepts = create_hierarchy(concepts, @rel_class, {})
    @concepts["root"].update_attribute("top_term", true)
  end

  test "entire hierarchy" do
    additional_concepts = YAML.load <<-EOS
boot:
  zoo:
  car:
    EOS
    @concepts.merge! create_hierarchy(additional_concepts, @rel_class, {})
    @concepts["boot"].update_attribute("top_term", true)

    get :index, { :lang => "en", :format => "ttl" }
    assert_response 200
    %w(root foo bar alpha bravo uno dos boot zoo car).each do |id|
      assert @response.body.include?(":#{id} a skos:Concept;"), "#{id} missing"
    end
    %w(lorem ipsum).each do |id|
      assert (not @response.body.include?(":#{id} a skos:Concept;")),
          "#{id} should not be present"
    end

    Iqvoc.config["performance.unbounded_hierarchy"] = true
    get :index, { :lang => "en", :format => "ttl" }
    assert_response 200

    %w(root foo bar alpha bravo uno dos lorem ipsum boot zoo car).each do |id|
      assert @response.body.include?(":#{id} a skos:Concept;"), "#{id} missing"
    end
  end

  test "permission handling" do
    get :show, :lang => "en", :format => "html", :root => "root"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = get_entries("ul.concept-hierarchy li li")
    assert_equal entries, ["Foo", "Bar"]
    entries = get_entries("ul.concept-hierarchy li li li")
    assert_equal entries, ["Alpha", "Bravo"]
    entries = get_entries("ul.concept-hierarchy li li li li")
    assert_equal entries, ["Uno", "Dos"]
    entries = css_select("ul.concept-hierarchy li li li li li")
    assert_equal entries.length, 0 # exceeded default depth

    @concepts["bar"].update_attribute("published_at", nil)

    get :show, :lang => "en", :format => "html", :root => "root"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = get_entries("ul.concept-hierarchy li li")
    assert_equal entries, ["Foo"]
    entries = get_entries("ul.concept-hierarchy li li li")
    assert_equal entries.length, 0
  end

  test "caching" do
    params = { :lang => "en", :format => "ttl", :root => "root" }

    # ETag generation & cache control

    get :show, params
    etag = @response.headers["ETag"]
    assert_response 200
    assert etag
    assert @response.headers["Cache-Control"].include?("public")

    get :show, params
    assert_response 200
    assert_equal etag, @response.headers["ETag"]

    get :show, params.merge(:published => "0")
    assert_response 200
    assert @response.headers["Cache-Control"].include?("private")

    # ETag keyed on params

    get :show, params.merge(:depth => 4)
    assert_response 200
    assert_not_equal etag, @response.headers["ETag"]

    get :show, params.merge(:published => 0)
    assert_response 200
    assert_not_equal etag, @response.headers["ETag"]

    # ETag keyed on (any in-scope) concept modification

    t0 = Time.now
    t1 = Time.now + 30

    dummy = create_concept("dummy", "Dummy", "en", false)
    dummy.update_attribute("updated_at", t1)
    get :show, params
    assert_response 200
    assert_equal etag, @response.headers["ETag"]

    dummy.update_attribute("published_at", t0)
    dummy.update_attribute("updated_at", t1)
    get :show, params
    assert_response 200
    new_etag = @response.headers["ETag"]
    assert_not_equal etag, new_etag

    # conditional caching

    @request.env["HTTP_IF_NONE_MATCH"] = new_etag
    get :show, params
    assert_response 304
    assert_equal 0, @response.body.strip.length

    @request.env["HTTP_IF_NONE_MATCH"] = "dummy"
    get :show, params
    assert_response 200
  end

  test "unsupported content type" do
    get :show, :lang => "en", :format => "N/A", :root => "root"
    assert_response 406
  end

  test "RDF representations" do
    # Turtle

    get :show, :lang => "en", :format => "ttl", :root => "root"
    assert_response 200
    assert_equal @response.content_type, "text/turtle"
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

    get :show, :lang => "en", :format => "ttl", :root => "lorem", :dir => "up"
    assert_response 200
    assert_equal @response.content_type, "text/turtle"
    assert @response.body.include?(<<-EOS)
:lorem a skos:Concept;
       skos:prefLabel "Lorem"@en;
       skos:broader :dos.
    EOS
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

    get :show, :lang => "en", :format => "rdf", :root => "root"
    assert_response 200
    assert_equal @response.content_type, "application/rdf+xml"
  end

  test "root parameter handling" do
    assert_raises(ActionController::RoutingError) do
      get :show, :format => "html"
    end

    get :show, :lang => "en", :format => "html", :root => "N/A"
    assert_response 404
    assert_equal flash[:error], "no concept matching root parameter"
    entries = css_select("ul.concept-hierarchy li")
    assert_equal entries.length, 0

    get :show, :lang => "en", :format => "html", :root => "root"
    assert_response 200
    assert_equal flash[:error], nil
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries.length, 1
    assert_equal entries[0], "Root"

    get :show, :lang => "en", :format => "html", :root => "root"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = get_entries("ul.concept-hierarchy li li")
    assert_equal entries, ["Foo", "Bar"]
    entries = get_entries("ul.concept-hierarchy li li li")
    assert_equal entries, ["Alpha", "Bravo"]
    entries = get_entries("ul.concept-hierarchy li li li li")
    assert_equal entries, ["Uno", "Dos"]
    entries = css_select("ul.concept-hierarchy li li li li li")
    assert_equal entries.length, 0 # exceeded default depth

    get :show, :lang => "en", :format => "html", :root => "bravo"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Bravo"]
    entries = get_entries("ul.concept-hierarchy li li")
    assert_equal entries, ["Uno", "Dos"]
    entries = get_entries("ul.concept-hierarchy li li li")
    assert_equal entries, ["Lorem", "Ipsum"]
    entries = css_select("ul.concept-hierarchy li li li li")
    assert_equal entries.length, 0

    get :show, :lang => "en", :format => "html", :root => "lorem"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Lorem"]
    entries = css_select("ul.concept-hierarchy li li")
    assert_equal entries.length, 0
  end

  test "depth handling" do
    selector = "ul.concept-hierarchy li li li li li"

    get :show, :lang => "en", :format => "html", :root => "root"
    entries = css_select(selector)
    assert_equal entries.length, 0 # default depth is 3

    get :show, :lang => "en", :format => "html", :root => "root", :depth => 4
    entries = css_select(selector)
    assert_equal entries.length, 2

    get :show, :lang => "en", :format => "html", :root => "root", :depth => 1
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = get_entries("ul.concept-hierarchy li li")
    assert_equal entries, ["Foo", "Bar"]
    entries = css_select("ul.concept-hierarchy li li li")
    assert_equal entries.length, 0

    get :show, :lang => "en", :format => "html", :root => "root", :depth => 5
    assert_response 403
    assert_equal flash[:error], "excessive depth"

    get :show, :lang => "en", :format => "html", :root => "root", :depth => "invalid"
    assert_response 400
    assert_equal flash[:error], "invalid depth parameter"
  end

  test "direction handling" do
    get :show, :lang => "en", :format => "html", :root => "root"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = get_entries("ul.concept-hierarchy li li li li")
    assert_equal entries, ["Uno", "Dos"]

    get :show, :lang => "en", :format => "html", :root => "root", :dir => "up"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = css_select("ul.concept-hierarchy li li")
    assert_equal entries.length, 0

    get :show, :lang => "en", :format => "html", :root => "lorem"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Lorem"]
    entries = css_select("ul.concept-hierarchy li li")
    assert_equal entries.length, 0

    get :show, :lang => "en", :format => "html", :root => "lorem", :dir => "up"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Lorem"]
    entries = get_entries("ul.concept-hierarchy li li li li")
    assert_equal entries, ["Bar"]
    entries = css_select("ul.concept-hierarchy li li li li li")
    assert_equal entries.length, 0

    get :show, :lang => "en", :format => "html", :root => "lorem", :dir => "up", :depth => 4
    page.all("ul.concept-hierarchy li").
        map { |node| node.native.children.first.text }
    entries = get_entries("ul.concept-hierarchy li li li li li")
    assert_equal entries, ["Root"]
  end

  test "siblings handling" do
    get :show, :lang => "en", :format => "html", :root => "foo"
    entries = get_all_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Foo"]

    get :show, :lang => "en", :format => "html", :root => "foo", :siblings => true
    entries = get_all_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Foo", "Bar"]

    get :show, :lang => "en", :format => "html", :root => "lorem"
    entries = get_all_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Lorem"]

    get :show, :lang => "en", :format => "html", :root => "lorem", :dir => "up",
        :siblings => true
    entries = get_all_entries("ul.concept-hierarchy li")
    assert_equal entries.length, 8
    ["Lorem", "Ipsum", "Uno", "Dos", "Alpha", "Bravo", "Bar", "Foo"].each do |name|
      assert entries.include?(name), "missing entry: #{name}"
    end

    get :show, :lang => "en", :format => "html", :root => "lorem", :dir => "up",
        :siblings => true, :depth => 4
    entries = get_all_entries("ul.concept-hierarchy li")
    assert_equal entries.length, 9
    ["Lorem", "Ipsum", "Uno", "Dos", "Alpha", "Bravo", "Bar", "Foo", "Root"].each do |name|
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

  def create_hierarchy(hash, rel_class, memo=nil, parent=nil)
    hash.each do |origin, children|
      concept = create_concept(origin, origin.capitalize, "en")
      memo[origin] = concept if memo
      link_concepts(parent, rel_class, concept) if parent
      create_hierarchy(children, rel_class, memo, concept) unless children.blank?
    end
    return memo
  end

  def link_concepts(source, rel_class, target)
      rel_name = rel_class.name.to_relation_name
      source.send(rel_name).create_with_reverse_relation(target)
  end

  def create_concept(origin, pref_label, label_lang, published=true)
    concept = Iqvoc::Concept.base_class.create(:origin => origin,
        :published_at => (published ? Time.now : nil))
    label = Iqvoc::Label.base_class.create(:value => pref_label,
        :language => label_lang)
    labeling = Iqvoc::Concept.pref_labeling_class.create(:owner => concept,
        :target => label)
    return concept
  end

end
