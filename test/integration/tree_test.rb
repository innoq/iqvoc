require 'test_helper'
require 'integration_test_helper'

class TreeTest < ActionDispatch::IntegrationTest

  setup do
  end

  test "Browse hierarchical concepts tree" do
    concept = Factory(:concept, :broader_relations => [])
    narrower_concept = concept.narrower_relations.first.target

    visit hierarchical_concepts_path(:lang => :de, :format => :html)
    assert page.has_link?(concept.pref_label.to_s), "Concept #{concept.pref_label} isn't visible in the hierarchical concepts list"
    assert !page.has_content?(narrower_concept.pref_label.to_s), "Narrower relation (#{narrower_concept.pref_label}) schouldn't be visible in the hierarchical concepts list"
  end

end
