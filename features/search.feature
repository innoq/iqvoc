Feature: Search labels and notes
  In order to find labels, notes or concepts
  As a visitor
  I want to be able to search with different criteria
  
  Scenario Outline: Searching
    Given I am a logged in user with the role reader
    And there are the following labelings
      | concept  | label           | labeling      |
      | _0000001 | Forest          | PrefLabeling  |
      | _0000002 | Tree            | PrefLabeling  |
      | _0000002 | ThingWithLeaves | AltLabeling   |
    And I am on the the search page
    When I indicate to search for "<type>" with "<query>" in "<languages>"
    And I choose "<query_type>" as query type
    And I execute the search
    Then there should be <amount> result
    And the results should contain "<result>"
    
    Examples:
      | type                      | query             | languages         | query_type | amount | result               |
      | bevorzugte Namen (Labels) | Forest            | Deutsch, English  | enthält    | 1      | Forest               |
      | alle Namen (Labels)       | thing with leaves | Deutsch, English  | enthält    | 1      | Thing With Leaves    |