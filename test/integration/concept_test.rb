require 'test_helper'
require 'integration_test_helper'

class ConceptTest < ActionDispatch::IntegrationTest
  
  setup do
    @concept = Factory.create(:concept_with_associations)
  end
  
  test "showing published concept" do
    visit "/de/concepts/_0000001"
    assert page.has_content?("_0000001")
  end

end
