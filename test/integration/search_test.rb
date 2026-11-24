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

  test 'labels of unpublished concepts are only found by users who may read them' do
    draft = Concept::Skos::Base.new.tap do |c|
      RdfApi.devour c, 'skos:prefLabel', '"Hidden"@en'
      c.publish
      c.save
    end
    draft.update_column(:published_at, nil)

    %w[labels pref_labels].each do |type|
      get search_path(lang: 'en', format: 'html', q: 'Hidden', t: type, l: ['en'])
      assert_response :success
      assert_select '.search-result', 0, "anonymous, #{type}"
    end

    login 'administrator'
    %w[labels pref_labels].each do |type|
      visit search_path(lang: 'en', format: 'html', q: 'Hidden', t: type, l: ['en'])
      assert_equal 1, page.all('.search-result').size, "administrator, #{type}"
    end
  end

  test 'additional parameters are passed on to the search class' do
    klass = Labeling::Skos::Base
    original = klass.method(:search_scope)
    received = nil
    klass.define_singleton_method(:search_scope) do |params = {}, &block|
      received = params
      original.call(params, &block)
    end

    begin
      get search_path(lang: 'en', format: 'html', q: 'Tree', t: 'labels', l: ['en'], date_min: '2012-01-01', sorting: 'descending')
      assert_response :success
    ensure
      klass.define_singleton_method(:search_scope, original)
    end

    assert_equal '2012-01-01', received[:date_min]
    assert_equal 'descending', received[:sorting]
    assert_equal 'Tree', received[:query] # long names for the search class
  end

  test 'number of queries does not depend on the number of results' do
    count_queries = lambda do |query|
      count = 0
      counter = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
        count += 1 unless %w[SCHEMA CACHE].include?(payload[:name])
      end
      begin
        get search_path(lang: 'en', format: 'html', q: query, t: 'labels', l: ['en'])
      ensure
        ActiveSupport::Notifications.unsubscribe(counter)
      end
      count
    end

    # both result lists fit on one page (per page = 5)
    { 'Pine' => 2, 'Elm' => 4 }.each do |name, amount|
      amount.times do |i|
        Concept::Skos::Base.new.tap do |c|
          RdfApi.devour c, 'skos:prefLabel', %("#{name} #{i}"@en)
          c.publish
          c.save
        end
      end
    end
    count_queries.call('Pine') # warm up caches

    few = count_queries.call('Pine')
    assert_select '.search-result', 2
    many = count_queries.call('Elm')
    assert_select '.search-result', 4

    assert_equal few, many, 'queries per result found (N+1)'
  end

  test 'number of queries for annotated notes does not depend on the number of results' do
    create_notes = lambda do |name, amount|
      amount.times do |i|
        concept = Concept::Skos::Base.new.tap do |c|
          RdfApi.devour c, 'skos:prefLabel', %("Concept #{name} #{i}"@en)
          c.publish
          c.save
        end
        note = Note::Skos::ChangeNote.create!(owner: concept, value: "#{name} #{i}", language: 'en')
        note.annotations.create!(namespace: 'dct', predicate: 'creator', value: 'someone')
        note.annotations.create!(namespace: 'dct', predicate: 'modified', value: '2026-01-01')
      end
    end
    create_notes.call('Pine', 2)
    create_notes.call('Elm', 4)

    count_queries = lambda do |query|
      count = 0
      counter = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
        count += 1 unless %w[SCHEMA CACHE].include?(payload[:name])
      end
      begin
        get search_path(lang: 'en', format: 'ttl', q: query, t: 'notes', l: ['en'])
        assert_response :success
      ensure
        ActiveSupport::Notifications.unsubscribe(counter)
      end
      count
    end

    count_queries.call('Pine') # warm up caches
    few = count_queries.call('Pine')
    many = count_queries.call('Elm')

    assert_equal few, many, 'queries per note found (N+1)'
  end

  test 'api searching without search parameter' do
    %w(ttl nt rdf).each do |format|
      get search_url(lang: 'en', format: format)
      assert_response :bad_request, 'should return bad request without search query'
    end
  end

  test 'api searching with blank search query' do
    %w(ttl nt rdf).each do |format|
      get search_url(lang: 'en', format: format, q: '')
      assert_response :success, "blank search query should be allowed for #{format}"
    end
  end

  test 'language parameter accepts lists and comma separated lists' do
    [{ 'l[]' => 'en' }, { l: 'en' }, { l: 'de,en' }].each do |lang_params|
      get search_path({ lang: 'en', format: 'html', q: 'Tree', t: 'labels' }.merge(lang_params))
      assert_response :success
      assert_select '.search-result', 1, lang_params.inspect
    end
  end

  test 'invalid query type is rejected' do
    %w[html ttl].each do |format|
      get search_path(lang: 'en', format: format, q: 'Tree', t: 'labels', qt: 'regexp')
      assert_response :bad_request
    end
  end

  test 'invalid search type is rejected' do
    get search_path(lang: 'en', format: 'html', q: 'Tree', t: 'nonsense')
    assert_response :bad_request

    get search_path(lang: 'en', format: 'ttl', q: 'Tree', t: 'nonsense')
    assert_response :bad_request
  end

  test 'note results are highlighted in html, fragment and ttl responses' do
    Concept::Skos::Base.new.tap do |c|
      RdfApi.devour c, 'skos:prefLabel', '"Oak"@en'
      RdfApi.devour c, 'skos:definition', '"A large tree"@en'
      c.publish
      c.save
    end

    get search_path(lang: 'en', format: 'html', q: 'tree', t: 'notes', l: 'en')
    assert_response :success
    assert_includes response.body, '<mark>tree</mark>'

    get search_path(lang: 'en', format: 'html', q: 'tree', t: 'notes', l: 'en'),
        headers: { 'Accept' => 'text/html; fragment=true' }
    assert_response :success
    assert_includes response.body, '<mark>tree</mark>'

    get rdf_search_path(format: 'ttl', q: 'tree', t: 'notes', l: 'en')
    assert_response :success
  end

  test 'long parameter names are still supported in URLs' do
    get search_path(lang: 'en', format: 'html', query: 'Tree', type: 'labels', query_type: 'exact', languages: ['en'])
    assert_response :success
    assert_select '.search-result', 1
    assert_select 'input[name=q][value=Tree]'
  end

  test 'short parameter names win over long ones' do
    get search_path(lang: 'en', format: 'html', q: 'Tree', query: 'Nothing', t: 'labels', l: ['en'])
    assert_response :success
    assert_select '.search-result', 1
  end

  test 'form is prefilled from short parameter names' do
    get search_path(lang: 'en', format: 'html', q: 'Tree', t: 'labels', qt: 'exact')
    assert_select 'input[name=q][value=Tree]'
    assert_select 'select#qt option[selected][value=exact]'
  end
end
