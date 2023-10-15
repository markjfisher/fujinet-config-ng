Feature: Stdlib library tests

  This tests stdlib library.

  Scenario Outline: Copying strings with _fc_strncpy
    Given atari application test setup
      And I add common/stdlib src file "fc_strncpy.s"
      And I add file for compiling "features/common/stdlib/test_fc_strncpy.s"
      And I create and load atari application

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
