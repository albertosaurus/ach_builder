Feature: ACH reader could parse ach-formatted files and make ruby copy of it

  Scenario Outline:
    Given <kind> ach file
    When I read this file with ach reader
    Then it should be converted to ach file instance

    When I take this ach file instance
    And I convert ach file instance to string
    And I cut tail with the nines
    Then string should be equal to given ach file

  Examples:
    | kind                     |
    | an empty wells fargo     |
    | an wells fargo with data |

  Scenario: parse empty correct ach file
    Given an empty wells fargo ach file
    When I read this file with ach reader
    And I take this ach file instance

    Then ach file instance should has "0" batches
    And ach file instance should has header

  Scenario: parse empty correct ach file with data
    Given an wells fargo with data ach file
    When I read this file with ach reader
    And I take this ach file instance

    Then ach file instance should has "1" batches
    And ach file instance should has header
