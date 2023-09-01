Feature: Stdlib library tests

  This tests stdlib library.

  Scenario Outline: Copying strings with _fn_strlcpy
    Given atari application test setup
      And I add common/stdlib src file "fn_strlcpy.s"
      And I add file for compiling "features/common/stdlib/test_fn_strlcpy.s"
      And I create and load application

     And I fill memory from t_src to t_src+127 with $ff
     And I write string "<string>" as ascii to memory address t_src
     And I write memory at t_c with <count>
     And I print ascii from t_src to t_src+128
     And I execute the procedure at _init for no more than 110 instructions
     And I print ascii from t_src to t_src+128

    # test the values in t_dst
    When I hex+ dump ascii between t_dst and t_dst+5
    Then property "test.BDD6502.lastHexDump" must contain string "<expected>"
     And I expect register A equal <return>
     And I expect register X equal $00

    Examples:
    | string       | count | return |   expected       | comment |
    | a            |   3   |   1    | : 61 00 ff ff ff | count > length, char + 0, no padding  |
    | ab           |   3   |   2    | : 61 62 00 ff ff | count > length, but only copy count-1 |
    | abc          |   3   |   3    | : 61 62 00 ff ff | count = length, truncate for nul      |
    | abcd         |   3   |   4    | : 61 62 00 ff ff | count < length, truncate for nul      |
