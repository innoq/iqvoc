@javascript

Scenario: Browse hierarchical concepts tree
  Given I have the concept hierarchy "Forest > Tree"
  And I am on the hierarchical concepts page
  Then I should see "Forest"
  And I should not see "Tree"