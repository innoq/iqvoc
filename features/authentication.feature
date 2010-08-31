Feature: Authentication
  In order to manage my authentication status
  As a user
  I want to either sign in or sign out
  
  Scenario: Signing in
    Given I am a logged out user
    When I go to the dashboard page
    Then I should see "Sie müssen angemeldet sein, um diese Seite aufzurufen"
    When I enter my credentials and sign in
    Then I should see "Anmeldung erfolgreich"
    
  Scenario: Signing out
    Given I am a logged in user with the role reader
    And I am on the home page
    When I follow "Abmelden"
    Then I should see "Abmeldung erfolgreich" 