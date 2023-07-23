Feature:  Hex library test

  This tests hex library.

  Scenario Outline: Using hex to output words
    Given atari application test setup
      And I add file for compiling "../../src/util/hex.s"
      And I add file for compiling "features/util/hex/test_hex_word.s"
      And I create and load application

      When I write word at t_vw with hex <input>
      And I execute the procedure at _init for no more than 110 instructions
      And I hex dump memory between output and output+4
     Then property "test.BDD6502.lastHexDump" must contain string "<output>"

    Examples:
    | input | output          | comment                              |
    | 0000  | : 30 30 30 30 : | digits 0-9 = 30-39 in ascii          |
    | 1234  | : 31 32 33 34 : |                                      |
    | 3456  | : 33 34 35 36 : |                                      |
    | 7890  | : 37 38 39 30 : |                                      |
    | abcd  | : 41 42 43 44 : | A-F hex caps = 41-46                 |
    | beef  | : 42 45 45 46 : | love me some beef                    |

  Scenario Outline: Using hexb to output bytes
    Given atari application test setup
      And I add file for compiling "../../src/util/hex.s"
      And I add file for compiling "features/util/hex/test_hex_byte.s"
      And I create and load application

    When I write word at t_vb with hex <input>
     And I execute the procedure at _init for no more than 65 instructions
     And I hex+ dump ascii between output and output+2
    Then property "test.BDD6502.lastHexDump" must contain string "<output>"

    Examples:
    | input | output    |
    | 01    | : 30 31 : |
    | ef    | : 45 46 : |
