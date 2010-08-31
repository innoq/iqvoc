Feature:
  As a visitor
  In order to inform myself about the product
  I want to browse static pages
  
  Scenario Outline: Show static pages
    And I am on the home page
    And I follow "<link>"
    Then I should be on the <target> page
    
    Examples:
    | link | target |
    | Über | about  |