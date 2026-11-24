require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class SearchQueryTest < ActiveSupport::TestCase
  def build(attrs = {})
    SearchQuery.new(attrs)
  end

  test 'applies defaults' do
    query = build

    assert_equal 'contains', query.query_type
    assert_equal 'all', query.for
    assert_equal false, query.include_expired
    assert_equal Iqvoc.searchable_class_names.values.first, query.type
    assert_equal SearchQuery.default_languages, query.languages
    refute query.submitted?
  end

  test 'a blank query counts as submitted' do
    query = build(query: '')

    assert query.submitted?
  end

  test 'languages accept lists and comma separated strings' do
    assert_equal %w[de en], build(languages: %w[de en]).language_codes
    assert_equal %w[de en], build(languages: 'de,en').language_codes
    assert_equal %w[de], build(languages: 'de').language_codes
  end

  test 'language "none" selects the nil language only' do
    assert_equal [nil], build(languages: %w[de none]).language_codes
  end

  test 'include_expired is true only for "true"' do
    assert build(include_expired: 'true').include_expired
    assert build(include_expired: true).include_expired
    refute build(include_expired: 'false').include_expired
    refute build(include_expired: nil).include_expired
  end

  test 'validates the query type' do
    assert build(query_type: 'exact').valid?
    assert build(query_type: '').valid?
    refute build(query_type: 'regexp').valid?
  end

  test 'validates the search type only when searching' do
    assert build(type: 'nonsense').valid?
    refute build(query: 'foo', type: 'nonsense').valid?
    assert build(query: 'foo', type: Iqvoc.searchable_class_names.values.first).valid?
  end

  test 'resolves the searchable class' do
    klass_name, type = Iqvoc.searchable_class_names.first

    assert_equal klass_name, build(type: type).search_class_name
    assert_equal klass_name.constantize, build(type: type).search_class
    assert_nil build(type: 'nonsense').search_class
  end

  test 'to_params uses attribute names' do
    params = build(query: 'foo', type: 'labels', languages: 'none').to_params

    assert_equal 'foo', params[:query]
    assert_equal 'labels', params[:type]
    assert_equal [nil], params[:languages]
    refute params.key?(:q)
  end

  test 'from_url_params maps short names to attributes' do
    query = SearchQuery.from_url_params(ActionController::Parameters.new(
      q: 'Tree', t: 'labels', qt: 'exact', l: %w[de en], c: 'col1', ds: %w[remote],
      for: 'concept', include_expired: 'true', note: 'n', change_note_type: 'created',
      change_note_date_from: '2026-01-01', change_note_date_to: '2026-02-01'
    ))

    assert_equal 'Tree', query.query
    assert_equal 'labels', query.type
    assert_equal 'exact', query.query_type
    assert_equal %w[de en], query.languages
    assert_equal 'col1', query.collection_origin
    assert_equal %w[remote], query.datasets
    assert_equal 'concept', query.for
    assert query.include_expired
    assert_equal 'n', query.note
    assert_equal 'created', query.change_note_type
    assert_equal '2026-01-01', query.change_note_date_from
    assert_equal '2026-02-01', query.change_note_date_to
  end

  test 'from_url_params still accepts long names' do
    query = SearchQuery.from_url_params(ActionController::Parameters.new(
      query: 'Tree', type: 'labels', query_type: 'exact', languages: %w[de],
      collection_origin: 'col1', datasets: %w[remote], foo: 'bar'
    ))

    assert_equal 'Tree', query.query
    assert_equal 'labels', query.type
    assert_equal 'exact', query.query_type
    assert_equal %w[de], query.languages
    assert_equal 'col1', query.collection_origin
    assert_equal %w[remote], query.datasets
  end

  test 'from_url_params prefers short over long names' do
    query = SearchQuery.from_url_params(ActionController::Parameters.new(
      q: 'Tree', query: 'Forest', qt: 'exact', query_type: 'begins_with'
    ))

    assert_equal 'Tree', query.query
    assert_equal 'exact', query.query_type
  end

  test 'from_url_params applies defaults for missing parameters' do
    query = SearchQuery.from_url_params(ActionController::Parameters.new({}))

    refute query.submitted?
    assert_equal SearchQuery.default_type, query.type
    assert_equal 'all', query.for
  end

  test 'to_url_params uses short names and normalized values' do
    query = SearchQuery.from_url_params(ActionController::Parameters.new(q: 'Tree', l: 'de,en', include_expired: 'true'))
    url_params = query.to_url_params

    assert_equal 'Tree', url_params[:q]
    assert_equal %w[de en], url_params[:l]
    assert_equal 'contains', url_params[:qt]
    assert_equal SearchQuery.default_type, url_params[:t]
    assert_equal true, url_params[:include_expired]
    assert_equal 'all', url_params[:for]
    %i[query type languages query_type collection_origin datasets].each do |long_name|
      refute url_params.key?(long_name), "#{long_name} must not be exposed"
    end
  end
end
