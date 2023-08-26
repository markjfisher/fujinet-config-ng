Feature: Stdlib library tests

  This tests stdlib library.

  Scenario Outline: Copying strings with _fn_strncpy
    Given atari application test setup
      And I add common/stdlib src file "fn_strncpy.s"
      And I add file for compiling "features/common/stdlib/test_fn_strncpy.s"
      And I create and load application

     And I fill memory from t_src to t_src+127 with $ff
     And I write string "<ascii_string>" as ascii to memory address t_src
     And I write memory at t_c with <count>
     And I print ascii from t_src to t_src+128
     And I execute the procedure at _init for no more than 200 instructions
     And I print ascii from t_src to t_src+128

    # test the values in t_dst
    When I hex+ dump ascii between t_dst and t_dst+5
    Then property "test.BDD6502.lastHexDump" must contain string "<expected>"

    Examples:
    | ascii_string | count |   expected       | comment |
    | a            |   3   | : 61 00 00 ff ff | count > length, pad zeros up to len   |
    | ab           |   3   | : 61 62 00 ff ff | count > length, pad zeros up to len   |
    | abc          |   3   | : 61 62 63 ff ff | count = length, no implicit nul added |
    | abcd         |   3   | : 61 62 63 ff ff | count < length, no implicit nul added |
    | abcde        |   3   | : 61 62 63 ff ff | count < length, no implicit nul added |

  Scenario Outline: Appending strings with _fn_strncat
    Given atari application test setup
      And I add common/stdlib src file "fn_strncat.s"
      And I add file for compiling "features/common/stdlib/test_fn_strncat.s"
      And I create and load application

     And I fill memory from t_src to t_src+127 with $ff
     And I write string "<dst>" as ascii to memory address t_dst
     And I write string "<src>" as ascii to memory address t_src
     And I print ascii from t_src to t_src+128
     And I write memory at t_c with <count>
     And I execute the procedure at _init for no more than 120 instructions
     And I print ascii from t_src to t_src+128

    # test the values in t_dst
    When I hex+ dump ascii between t_dst and t_dst+6
    Then property "test.BDD6502.lastHexDump" must contain string "<expected>"

    Examples:
    | src   | dst | count |   expected          | comment |
    | a     | x   |   4   | : 78 61 00 ff ff ff | count > length, only copy 1 and null |
    | ab    | x   |   4   | : 78 61 62 00 ff ff | count > length, copy both and null   |
    | abc   | x   |   4   | : 78 61 62 63 00 ff | count > length, copy all 3 and null  |
    | abcd  | x   |   4   | : 78 61 62 63 00 ff | count = length, max 4, always nul terminated |
    | abcde | x   |   4   | : 78 61 62 63 00 ff | count < length, as above             |
