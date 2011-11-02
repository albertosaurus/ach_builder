Feature: Ach reader could read ach files and make it ruby object copy

  Scenario:
    Given an empty wells fargo ach file
    When I read this file with ach reader
    Then it should be converted to ach file instance