Feature:  Hex library test

  This tests hex library.

  Scenario Outline: Using hex to output words in hexidecimal
    Given basic setup test "hex"

    And I mads-compile "hex" from "../../src/libs/util/hex.asm"
    And I build and load the application "test_hex" from "features/util/hex/test_hex.asm"

    When I write word at t_vw with hex <input>
     And I execute the procedure at begin_test_word for no more than 200 instructions
     And I hex dump memory between output and output+4
    Then property "test.BDD6502.lastHexDump" must contain string "<output>"

    Examples:
    | input | output          | comment                              |
    | 0000  | : 10 10 10 10 : | digits 0-9 = 10-19 in d'1234' format |
    | 1234  | : 11 12 13 14 : |                                      |
    | 3456  | : 13 14 15 16 : |                                      |
    | 7890  | : 17 18 19 10 : |                                      |
    | abcd  | : 21 22 23 24 : | A-F hex caps = 21-26                 |
    | beef  | : 22 25 25 26 : | love me some beef                    |

  Scenario Outline: Using hexb to output bytes in hexidecimal
    Given basic setup test "hexb"

    And I mads-compile "hex" from "../../src/libs/util/hex.asm"
    And I build and load the application "test_hex" from "features/util/hex/test_hex.asm"

    When I write word at t_vb with hex <input>
     And I execute the procedure at begin_test_byte for no more than 200 instructions
     And I hex dump memory between output and output+2
    Then property "test.BDD6502.lastHexDump" must contain string "<output>"

    Examples:
    | input | output    |
    | 01    | : 10 11 : |
    | ef    | : 25 26 : |
