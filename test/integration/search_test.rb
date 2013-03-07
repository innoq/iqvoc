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

require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

class SearchTest < ActionDispatch::IntegrationTest

  setup do
    DatabaseCleaner.start
    @pagination_setting = Kaminari.config.default_per_page
    Kaminari.config.default_per_page = 5

    Iqvoc::RDFAPI.parse_triples <<-EOT
      :tree rdf:type skos:Concept
      :tree skos:prefLabel "Tree"@en
      :tree iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>

      :forest rdf:type skos:Concept
      :forest skos:prefLabel "Forest"@en
      :forest iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>

      :alpha rdf:type skos:Collection
      :alpha skos:prefLabel "Alpha"@en
      :alpha iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>
      :alpha skos:member :tree
      :alpha skos:member :forest
    EOT

    @collection = Iqvoc::RDFAPI.cached(:alpha)
  end

  teardown do
    DatabaseCleaner.clean
    Kaminari.config.default_per_page = @pagination_setting
  end

  test 'searching' do
    visit search_path(:lang => 'en', :format => 'html')

    [{ :type => 'Labels', :query => 'Forest', :query_type => 'contains',
        :amount => 1, :result => 'Forest' }].each do |q|
      find('#t').select q[:type]
      fill_in 'Search term(s)', :with => q[:query]
      find('#qt').select q[:query_type]

      # select all languages
      page.all(:css, '.lang_check').each do |cb|
        check cb[:id]
      end

      click_button('Search')

      assert page.has_css?('#search_results dt', :count => q[:amount]),
      "Page has #{page.all(:css, '#search_results dt').count} '#search_results dt' nodes. Should be #{q[:amount]}."

      within('#search_results dt') do
        assert page.has_content?(q[:result]), "Could not find '#{q[:result]}' within '#search_results dt'."
      end
    end
  end

  test 'collection/concept filter' do
    visit search_path(:lang => 'en', :format => 'html')

    find('#t').select 'Labels'
    find('#qt').select 'contains'
    fill_in 'Search term(s)', :with => 'Alpha'
    click_button('Search')
    assert page.has_css?('#search_results dt', :count => 1)

    choose 'Concepts'
    click_button 'Search'
    assert page.has_no_css?('#search_results dt')

    choose 'Collections'
    click_button 'Search'
    assert page.has_css?('#search_results dt')
  end

  test 'searching within collections' do
    visit search_path(:lang => 'en', :format => 'html')

    find('#t').select 'Labels'
    find('#qt').select 'contains'
    fill_in 'Search term(s)', :with => 'res'
    find('#c').select @collection.to_s

    # select all languages
    page.all(:css, '.lang_check').each do |cb|
      check cb[:id]
    end

    click_button('Search')

    assert page.has_css?('#search_results dt', :count => 1)
    assert page.find('#search_results').has_content?('Forest')

    # TTL & RDF/XML

    ttl_uri = page.find('#rdf_link_ttl')[:href]
    xml_uri = page.find('#rdf_link_xml')[:href]

    visit ttl_uri
    assert page.has_content?('search:result1 a sdc:Result')
    assert page.has_no_content?('search:result2 a sdc:Result')
    assert page.has_content?('sdc:link :forest')
    assert page.has_content?('skos:prefLabel "Forest"@en')

    visit xml_uri
    assert page.source.include?('forest')
    assert page.source.include?('<skos:prefLabel xml:lang="en">Forest</skos:prefLabel>')
  end

  test 'searching specific classes within collections' do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :lorem rdf:type skos:Concept
      :lorem skos:prefLabel "Lorem of the Ipsum"@en
      :lorem skos:example "lorem ipsum"@en
      :lorem iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>
    EOT

    visit search_path(:lang => 'en', :format => 'html')

    find('#t').select 'Notes'
    find('#qt').select 'contains'
    fill_in 'Search term(s)', :with => 'ipsum'
    find('#c').select @collection.to_s

    # select all languages
    page.all(:css, '.lang_check').each do |cb|
      check cb[:id]
    end

    click_button('Search')

    assert page.has_css?('#search_results dt', :count => 1)
    assert page.find('#search_results').has_content?(concept.origin)
  end

  test 'empty query with selected collection should return all collection members' do
    visit search_path(:lang => 'en', :format => 'html')

    find('#t').select 'Labels'
    find('#qt').select 'exact match'
    fill_in 'Search term(s)', :with => ''
    find('#c').select @collection.to_s

    # select all languages
    page.all(:css, '.lang_check').each do |cb|
      check cb[:id]
    end

    click_button('Search')

    assert page.has_css?('#search_results dt', :count => 2)
    assert page.find('#search_results').has_content?('Tree')
    assert page.find('#search_results').has_content?('Forest')
  end

  test 'pagination' do
    # create a "large" number of concepts
    12.times do |i|
      Iqvoc::RDFAPI.parse_triples <<-EOT
        :_#{i} rdf:type skos:Concept
        :_#{i} skos:prefLabel "sample_#{sprintf('_%04d', i + 1)}"@en
        :_#{i} iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>
      EOT
    end

    visit search_path(:lang => 'en', :format => 'html')

    find('#t').select 'Labels'
    find('#qt').select 'contains'
    fill_in 'Search term(s)', :with => 'sample_'

    click_button('Search')

    assert page.has_css?('#search_results dt', :count => 5)
    assert page.has_css?('.pagination .page', :count => 3)

    find('.pagination').all('.page').last.find('a').click

    assert page.has_css?('#search_results dt', :count => 2)

    # TTL & RDF/XML

    ttl_uri = page.find('#rdf_link_ttl')[:href]
    xml_uri = page.find('#rdf_link_xml')[:href]

    visit ttl_uri
    assert page.has_content?('sdc:totalResults 12;')
    assert page.has_content?('sdc:itemsPerPage 5;')
    assert page.has_content?('search:result1 a sdc:Result;')
    assert page.has_content?('search:result2 a sdc:Result;')
    assert page.has_no_content?('search:result3 a sdc:Result;') # we're on page 3/3

    visit xml_uri
    assert page.source.include?('<sdc:totalResults rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">12</sdc:totalResults>')
    assert page.source.include?('<sdc:itemsPerPage rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">5</sdc:itemsPerPage>')
    assert page.source.include?('#result1">')
    assert page.source.include?('#result2">')
    assert !page.source.include?('#result3">') # we're on page 3/3
  end

end
