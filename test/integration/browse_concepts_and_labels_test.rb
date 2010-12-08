require 'test_helper'
require 'integration_test_helper'

class BrowseConceptsAndLabelsTest < ActionDispatch::IntegrationTest

  setup do
    @concept1 = Factory(:concept)
    @concept1.pref_label.value = "Tree"
    @concept1.pref_label.save!
    @concept2 = Factory(:concept)
    @concept2.pref_label.value = "Forrest"
    @concept2.pref_label.save!
  end

  test "Selecting a concept in alphabetical view" do
    visit alphabetical_concepts_path(:lang => 'de', :letter => @concept1.pref_label.to_s[0, 1], :format => :html)
    assert page.has_link?(@concept1.pref_label.to_s), "Concept '#{@concept1.pref_label}' not found on alphabetical concepts list (letter: #{@concept1.pref_label.to_s[0, 1]})"
    assert !page.has_content?(@concept2.pref_label.to_s), "Found concept '#{@concept2.pref_label}' on alphabetical concepts list (letter: #{@concept1.pref_label.to_s[0, 1]})"
    click_link_or_button(@concept1.pref_label.to_s)
    assert_equal concept_path(@concept1, :lang => 'de', :format => :html), URI.parse(current_url).path
  end

end

=begin
  Scenario: Showing a concept page
    Given I am a logged in user with the role reader
    And I have concepts _0000001 labeled Forest
    And I am on the concept page for "_0000001"
    Then I should see "Bevorzugtes Label: Forest"
    When I follow the link to the format representation for ttl
    Then I should see a Turtle representation for the concept "_0000001"
  
  Scenario: Showing a label page
    Given I am a logged in user with the role reader
    And I have concepts _0000001 labeled Forest
    And I am on the concept page for "_0000001"
    When I follow "Forest"
    Then I should be on the label page for "Forest"
    And I should see "Label: Forest"
    When I follow the link to the format representation for ttl
    Then I should see a Turtle representation for the concept "_0000001"

=end