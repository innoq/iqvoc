require 'test_helper'
require 'integration_test_helper'

class ConceptTest < ActionDispatch::IntegrationTest
  
  setup do
    @concept = Factory(:concept_with_associations)
  end
  
  test "showing published concept" do
    visit "/de/concepts/#{@concept.origin}.html"
    assert page.has_content?("#{@concept.origin}")
    assert page.has_content?("#{@concept.pref_label}")
  end

end
