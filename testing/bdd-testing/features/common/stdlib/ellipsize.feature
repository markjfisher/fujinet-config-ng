Feature: Ellipsize tests

  This tests ellipsize string functionality.

  Scenario Outline: Strings are ellipsized if they are larger than the max length, or simply copied otherwise
    Given atari application test setup
      And I add common/stdlib src file "ellipsize.s"
      And I add common/stdlib src file "fc_strncpy.s"
      And I add common/stdlib src file "fn_strlen.s"
      And I add file for compiling "features/common/stdlib/test_ellipsize.s"
      And I create and load atari application

     And I fill memory from t_src to t_src+127 with $ff
     And I write string "<input>" as ascii to memory address t_src
     And I write memory at t_max with <max>
     And I print ascii from t_src to t_src+128
     And I execute the procedure at _init for no more than <cnt> instructions
     And I print ascii from t_src to t_src+128

    # test the values in t_dst.
    When I hex+ dump ascii between t_dst and t_dst+10
    # this checks the $00 and $ff are in expected places
    Then property "test.BDD6502.lastHexDump" must contain string "<bytes>"
     # This makes test easier to read, the offset is always 0, the string is then as given in Examples, but the hex test above tests ascii hex bytes
     And string at t_dst contains
     """
     0:<string>
     """

    # memory is filled with $ff so we can see exactly what was written including $00 null terminator
    Examples:
    | input        | max | cnt |   bytes                        | string  | comment                |
    | 12345        |  8  | 200 | : 31 32 33 34 35 00 ff         | 12345   | not changed, too small |
    | 123456789    |  8  | 178 | : 31 32 2e 2e 2e 38 39 00  ff  | 12...89 | 12...89<0> = 7+1 = 8   |
    | abc456789xyz |  6  | 183 | : 61 2e 2e 2e 7a 00 ff         | a...z   | a...z<0>   = 5+1 = 6   |
