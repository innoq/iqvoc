require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

# `single_query` (array of SearchResult, used by other gems) and `search_scope`
# (relation, used for SQL pagination) have to stay consistent.
class SearchScopeTest < ActiveSupport::TestCase
  setup do
    %w("Tree"@en "Forest"@en).each do |literal|
      Concept::Skos::Base.new.tap do |c|
        RdfApi.devour c, 'skos:prefLabel', literal
        c.publish
        c.save
      end
    end
  end

  def params(attrs = {})
    SearchQuery.new({ query: '' }.merge(attrs)).to_params
  end

  [Labeling::Skos::Base, Labeling::Skos::PrefLabel, Note::Base].each do |klass|
    test "#{klass} search_scope is a relation" do
      assert_kind_of ActiveRecord::Relation, klass.search_scope(params)
    end

    test "#{klass} single_query wraps the results of search_scope" do
      results = klass.single_query(params)

      assert results.all?(SearchResult)
      assert_equal klass.search_scope(params).map(&:id).sort, results.map { |r| r.result_object.id }.sort
    end

    test "#{klass} readable_by restricts a relation" do
      assert_kind_of ActiveRecord::Relation, klass.search_scope(params).readable_by(Ability.new(nil))
    end
  end

  test 'a block extends the scope of search_scope and single_query' do
    scope = Labeling::Skos::PrefLabel.search_scope(params(query: 'Tree')) { |s| s.where('1 = 0') }
    assert_empty scope

    assert_empty Labeling::Skos::PrefLabel.single_query(params(query: 'Tree')) { |s| s.where('1 = 0') }
    assert_equal 1, Labeling::Skos::PrefLabel.single_query(params(query: 'Tree')).size
  end

  test 'search_scope paginates in SQL' do
    scope = Labeling::Skos::PrefLabel.search_scope(params).page(1).per(1)

    assert_equal 1, scope.to_a.size
    assert_equal 2, scope.total_count
  end
end
