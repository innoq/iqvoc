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

require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

class SearchTest < ActionDispatch::IntegrationTest
  setup do
    @pagination_setting = Kaminari.config.default_per_page
    Kaminari.config.default_per_page = 5

    @concepts = %w("Tree"@en "Forest"@en).map do |literal|
      Concept::Skos::Base.new.tap do |c|
        RdfApi.devour c, 'skos:prefLabel', literal
        c.publish
        c.save
      end
    end

    @collection = Collection::Skos::Unordered.new.tap do |c|
      RdfApi.devour c, 'skos:prefLabel', '"Alpha"@en'
      c.publish
      c.save
    end

    # assign concepts to collection
    @concepts.each do |c|
      RdfApi.devour @collection, 'skos:member', c
    end
  end

  teardown do
    Kaminari.config.default_per_page = @pagination_setting
  end

  test 'searching' do
    visit search_path(lang: 'en', format: 'html')

    [{
       type: 'Labels', query: 'Forest', query_type: 'contain keyword',
       amount: 1, result: 'Forest'
     }].each { |q|
      find('#t').select q[:type]
      fill_in 'Search term(s)', with: q[:query]
      find('#qt').select q[:query_type]

      # select all languages
      page.all(:css, '.lang_check').each do |cb|
        check cb[:id]
      end

      click_button('Search')

      assert page.has_css?('.search-result', count: q[:amount]),
             "Page has #{page.all(:css, '.search-result').count} '.search-result' nodes. Should be #{q[:amount]}."

      within('.search-result') do
        assert page.has_content?(q[:result]), "Could not find '#{q[:result]}' within '.search-result'."
      end
    }
  end

  test 'collection/concept filter' do
    visit search_path(lang: 'en', format: 'html')

    find('#t').select 'Labels'
    find('#qt').select 'contain keyword'
    fill_in 'Search term(s)', with: 'Alpha'
    click_button('Search')
    assert page.has_css?('.search-result', count: 1)

    choose 'Concepts'
    click_button 'Search'
    assert page.has_no_css?('.search-result')

    choose 'Collections'
    click_button 'Search'
    assert page.has_css?('.search-result')
  end

  test 'date filter' do
    login 'administrator'

    visit new_concept_path(lang: 'en', format: 'html', published: 0)
    fill_in 'concept_labelings_by_text_labeling_skos_pref_labels_en',
        with: 'Water'
    click_button 'Save'

    visit new_concept_path(lang: 'en', format: 'html', published: 0)
    fill_in 'concept_labelings_by_text_labeling_skos_pref_labels_en',
        with: 'Air'
    click_button 'Save'

    Iqvoc::Concept.base_class.third.update(published_at: Date.today)
    Iqvoc::Concept.base_class.fourth.update(published_at: Date.today)
    Note::Annotated::Base.where(predicate: "created").first.update(value: (Date.today - 10.days).to_s)

    visit search_path(lang: 'en', format: 'html')
    find('#t').select 'Labels'
    find('#change_note_type').select 'creation date'
    fill_in 'change_note_date_from', with: Date.today
    click_button('Search')

    refute page.find('.search-results').has_content?('Water')
    assert page.find('.search-results').has_content?('Air')
  end

  test 'searching within collections' do
    visit search_path(lang: 'en', format: 'html')

    find('#t').select 'Labels'
    find('#qt').select 'contain keyword'
    fill_in 'Search term(s)', with: 'res'
    find('#c').select @collection.to_s

    # select all languages
    page.all(:css, '.lang_check').each do |cb|
      check cb[:id]
    end

    click_button('Search')

    assert page.has_css?('.search-result', count: 1)
    assert page.find('.search-results').has_content?('Forest')

    # TTL & RDF/XML

    ttl_uri = page.find('#rdf_link_ttl')[:href]
    xml_uri = page.find('#rdf_link_xml')[:href]

    visit ttl_uri
    assert page.has_content?('search:result1 a sdc:Result')
    assert page.has_no_content?('search:result2 a sdc:Result')
    assert page.has_content?("sdc:link :#{@concepts[1].origin}")
    assert page.has_content?('skos:prefLabel "Forest"@en')

    visit xml_uri
    assert page.source.include?(@concepts[1].origin)
    assert page.source.include?("<skos:prefLabel xml:lang=\"en\">#{@concepts[1].to_s}</skos:prefLabel>")
  end

  test 'searching specific classes within collections' do
    concept = Concept::Skos::Base.new.tap do |c|
      RdfApi.devour c, 'skos:definition', '"lorem ipsum"@en'
      c.publish
      c.save
    end
    RdfApi.devour @collection, 'skos:member', concept

    visit search_path(lang: 'en', format: 'html')

    find('#t').select 'Notes'
    find('#qt').select 'contain keyword'
    fill_in 'Search term(s)', with: 'ipsum'
    find('#c').select @collection.to_s

    # select all languages
    page.all(:css, '.lang_check').each do |cb|
      check cb[:id]
    end

    click_button('Search')

    assert page.has_css?('.search-result', count: 1)
    assert page.find('.search-results').has_content?(concept.pref_label.to_s)
  end

  test 'empty query with selected collection should return all collection members' do
    visit search_path(lang: 'en', format: 'html')

    find('#t').select 'Labels'
    find('#qt').select 'exactly match'
    fill_in 'Search term(s)', with: ''
    find('#c').select @collection.to_s

    # select all languages
    page.all(:css, '.lang_check').each do |cb|
      check cb[:id]
    end

    click_button('Search')

    assert page.has_css?('.search-result', count: 2)
    assert page.find('.search-results').has_content?('Tree')
    assert page.find('.search-results').has_content?('Forest')
  end

  test 'pagination' do
    # create a large number of concepts
    1.upto(12) do |i|
      Concept::Skos::Base.new.tap do |c|
        RdfApi.devour c, 'skos:prefLabel', "\"sample_#{sprintf('_%04d', i)}\"@en"
        c.publish
        c.save
      end
    end

    visit search_path(lang: 'en', format: 'html')

    find('#t').select 'Labels'
    find('#qt').select 'contain keyword'
    fill_in 'Search term(s)', with: 'sample_'

    click_button('Search')

    assert page.has_css?('.search-result', count: 5)
    assert page.has_css?('.pagination .page-item', count: 5)

    find('.pagination').all('.page-item').last.find('a').click

    assert page.has_css?('.search-result', count: 2)

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

  test 'api searching with empty search query' do
    %w(ttl nt rdf).each do |format|
      get search_url(lang: 'en', format: format)
      assert_response :bad_request, 'should return bad request without search query'

      get search_url(lang: 'en', format: format, query: '')
      assert_response :bad_request, 'should return bad request with blank search query'
    end
  end
end
