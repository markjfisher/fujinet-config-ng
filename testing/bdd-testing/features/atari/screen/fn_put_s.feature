Feature: Screen Functions test - _fn_put_s

  This tests Atari screen function _fn_put_s to place a string within the display area

  Scenario: Running _fn_put_s puts a string that fits on a line without cropping at border
    Given atari application test setup
      And I add atari/screen src file "fn_put_s.s"
      And I add atari/screen src file "fn_get_scrloc.s"
      And I add atari/screen src file "fn_screen_mem.s"
      And I add file for compiling "features/atari/screen/test_fn_put_s.s"
      And I create and load application
      And I write memory at t_x with 0
      And I write memory at t_y with 0
      And I write string "this string fits!" as ascii to memory address t_s
      And I execute the procedure at _init for no more than 350 instructions
    
     Then screen memory at m_l1 contains ascii
     """
     {inv} {inv} this string fits!                    {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}
     """

  Scenario: Running _fn_put_s puts a string but crops it at the border
    Given atari application test setup
      And I add atari/screen src file "fn_put_s.s"
      And I add atari/screen src file "fn_get_scrloc.s"
      And I add atari/screen src file "fn_screen_mem.s"
      And I add file for compiling "features/atari/screen/test_fn_put_s.s"
      And I create and load application
      And I write memory at t_x with 25
      And I write memory at t_y with 0
      And I write string "this does not!" as ascii to memory address t_s
      And I execute the procedure at _init for no more than 250 instructions
    
     Then screen memory at m_l1 contains ascii
     """
     {inv} {inv}                          this does n {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}
     """
