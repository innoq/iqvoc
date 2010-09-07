Feature: Browse concepts and labels
  In order to browse concepts labels
  As a visitor
  I want to browse the concepts in different views and dig into concepts and labels
    
  Scenario: Selecting a concept in alphabetical view
    Given I am a logged in user with the role reader
    And I have concepts _0000001, _0000002 labeled Forest, Tree
    And I am on the alphabetical concepts page for the letter "f"
    Then I should see "Forest"
    And I should not see "Tree"
    When I follow "Forest"
    Then I should be on the concept page for "_0000001"
    
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
    