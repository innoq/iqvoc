Scenario: Create a new concept version
  Given I am a logged in user with the role administrator
  And I have concepts _0000001 labeled Forest
  And I am on the concept page for "_0000001"
  Then I should see a button to create a new version
  When I press "Neue Version erstellen"
  Then I should be on the edit versioned concept page for "_0000001"
  When I go to the concept page for "_0000001"
  Then I should not see a button to create a new version
  When I follow "Vorschau der Version in Bearbeitung"
  Then I should be on the versioned concept page for "_0000001"