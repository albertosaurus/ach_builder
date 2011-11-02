Feature: ACH reader could parse ach-formatted files and make ruby copy of it

  Scenario Outline:
    Given <kind> ach file
    When I read this file with ach reader
    Then it should be converted to ach file instance

  Examples:
    | kind                     |
    | an empty wells fargo     |
    | an wells fargo with data |