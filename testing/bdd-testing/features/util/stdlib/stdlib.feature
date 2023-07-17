Feature: Stdlib library tests

  This tests stdlib library.

  Scenario Outline: Copying strings with strcpy
    Given basic setup test "stdlib"

     And I mads-compile "stdlib" from "../../src/libs/util/stdlib.asm"
     And I build and load the application "test_stdlib" from "features/util/stdlib/test_stdlib.asm"

     # memory will already be 0 terminated
     And I write string "<ascii_string>" as ascii to memory address src
     # And I print ascii from src to src+16
     And I execute the procedure at begin_test_strcpy for no more than 100 instructions

    # test the values in dst
    When I hex+ dump ascii between dst and dst+16
    Then property "test.BDD6502.lastHexDump" must contain string "<ascii_string>"

    Examples:
    | ascii_string |
    | 0123456789   |
    | hello world! |

  Scenario Outline: Appending strings with strappend
    Given basic setup test "stdlib"

     And I mads-compile "stdlib" from "../../src/libs/util/stdlib.asm"
     And I build and load the application "test_stdlib" from "features/util/stdlib/test_stdlib.asm"

     And I write string "<src>" as ascii to memory address src
     And I execute the procedure at begin_test_strcpy for no more than 200 instructions
     And I write string "<append>" as ascii to memory address src
     And I execute the procedure at begin_test_strappend for no more than 200 instructions

    # test the values in dst
    When I hex+ dump ascii between dst and dst+16
    Then property "test.BDD6502.lastHexDump" must contain string "<result>"

    Examples:
    | src     | append | result       |
    | 01234   | 56789  | 0123456789   |
    | hello w | orld!  | hello world! |
