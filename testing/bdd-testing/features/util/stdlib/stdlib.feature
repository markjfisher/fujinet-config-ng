Feature: Stdlib library tests

  This tests stdlib library.

  Scenario Outline: Copying strings with strncpy
    Given basic setup test "stdlib"

     And I mads-compile "stdlib" from "../../src/libs/util/stdlib.asm"
     And I build and load the application "test_stdlib" from "features/util/stdlib/test_stdlib.asm"

     And I fill memory from src to src+129 with $ff
     And I write string "<ascii_string>" as ascii to memory address src
     And I write memory at count with <count>
     And I execute the procedure at begin_test_strncpy for no more than 200 instructions
     And I print ascii from src to src+129

    # test the values in dst
    When I hex+ dump ascii between dst and dst+5
    Then property "test.BDD6502.lastHexDump" must contain string "<expected>"

    Examples:
    | ascii_string | count |   expected       | comment |
    | a            |   3   | : 61 00 00 ff ff | count > length, pad zeros up to len   |
    | ab           |   3   | : 61 62 00 ff ff | count > length, pad zeros up to len   |
    | abc          |   3   | : 61 62 63 ff ff | count = length, no implicit nul added |
    | abcd         |   3   | : 61 62 63 ff ff | count < length, no implicit nul added |
    | abcde        |   3   | : 61 62 63 ff ff | count < length, no implicit nul added |

  Scenario Outline: Appending strings with strncat
    Given basic setup test "stdlib"

     And I mads-compile "stdlib" from "../../src/libs/util/stdlib.asm"
     And I build and load the application "test_stdlib" from "features/util/stdlib/test_stdlib.asm"

     And I fill memory from src to src+129 with $ff
     And I write string "<dst>" as ascii to memory address dst
     And I write string "<src>" as ascii to memory address src
     And I print ascii from src to src+129
     And I write memory at count with <count>
     And I execute the procedure at begin_test_strncat for no more than 100 instructions
     And I print ascii from src to src+129

    # test the values in dst
    When I hex+ dump ascii between dst and dst+6
    Then property "test.BDD6502.lastHexDump" must contain string "<expected>"

    Examples:
    | src   | dst | count |   expected          | comment |
    | a     | x   |   4   | : 78 61 00 ff ff ff | count > length, only copy 1 and null |
    | ab    | x   |   4   | : 78 61 62 00 ff ff | count > length, copy both and null   |
    | abc   | x   |   4   | : 78 61 62 63 00 ff | count > length, copy all 3 and null  |
    | abcd  | x   |   4   | : 78 61 62 63 00 ff | count = length, max 4, always nul terminated |
    | abcde | x   |   4   | : 78 61 62 63 00 ff | count < length, as above             |
