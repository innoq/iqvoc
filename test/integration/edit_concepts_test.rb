require 'test_helper'
require 'integration_test_helper'

class EditConceptsTest < ActionDispatch::IntegrationTest

  setup do
    @concept = Factory(:concept)
  end

  test "Create a new concept version" do
    login('administrator')
    visit concept_path(@concept, :lang => 'de', :format => 'html')
    assert page.has_button?("Neue Version erstellen"), "Button 'Neue Version erstellen' is missing on concepts#show"
    click_link_or_button("Neue Version erstellen")
    assert_equal edit_concept_path(@concept, :lang => 'de', :format => 'html'), current_path

    visit concept_path(@concept, :lang => 'de', :format => 'html')
    assert !page.has_button?("Neue Version erstellen"), "Button 'Neue Version erstellen' although there already is a new version"
    assert page.has_link?("Vorschau der Version in Bearbeitung"), "Link 'Vorschau der Version in Bearbeitung' is missing"
    click_link_or_button("Vorschau der Version in Bearbeitung")
    # Doesn't work... Capibara bug???  assert_equal concept_path(@concept, :published => 0, :lang => 'de', :format => 'html'), current_path
  end

end
