Feature: Screen Functions test - _fn_put_help

  This tests Atari screen function _fn_put_help to place a help string on correct line

  Scenario: Running _fn_put_help puts help string on first line
    Given atari application test setup
      And I add atari src file "common/screen/fn_put_msg.s"
      And I add atari src file "common/screen/fn_put_s.s"
      And I add atari src file "common/screen/fn_get_scrloc.s"
      And I add atari src file "common/screen/fn_screen_mem.s"
      And I add common stdlib files
      And I add file for compiling "features/atari/common/screen/test_fn_put_help.s"
      And I create and load application
      And I write memory at t_y with 0
      And I write encoded string "{inv}       super amazing help message       {inv}" to t_s
      And I execute the procedure at _init for no more than 1000 instructions
    
    # Then screen memory at mhlp1 contains ascii
    # """
    # {inv}       super amazing help message       {inv}\
    # {inv}                                        {inv}
    # """
     # Only doing this once to illustrate alternate way of testing, but also to double check the screen memory routines
     When I hex+ dump memory between mhlp1 and mhlp1+40
     Then property "test.BDD6502.lastHexDump" must contain string ": 80 80 80 80 80 80 80 f3  f5 f0 e5 f2 80 e1 ed e1 :"
     Then property "test.BDD6502.lastHexDump" must contain string ": fa e9 ee e7 80 e8 e5 ec  f0 80 ed e5 f3 f3 e1 e7 :"
     Then property "test.BDD6502.lastHexDump" must contain string ": e5 80 80 80 80 80 80 80 :"

  # Scenario: Running _fn_put_help puts help string on second line
  #   Given atari application test setup
  #     And I add atari src file "common/screen/fn_put_msg.s"
  #     And I add atari src file "common/screen/fn_put_s.s"
  #     And I add atari src file "common/screen/fn_get_scrloc.s"
  #     And I add atari src file "common/screen/fn_screen_mem.s"
  #     And I add common stdlib files
  #     And I add file for compiling "features/atari/common/screen/test_fn_put_help.s"
  #     And I create and load application
  #     And I write memory at t_y with 1
  #     And I write encoded string "{inv}      another amazing help message      {inv}" to t_s
  #     And I execute the procedure at _init for no more than 1000 instructions
    
  #    Then screen memory at mhlp1 contains ascii
  #    """
  #    {inv}                                        {inv}\
  #    {inv}      another amazing help message      {inv}
  #    """
