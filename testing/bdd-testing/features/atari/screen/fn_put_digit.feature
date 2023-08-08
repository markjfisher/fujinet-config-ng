Feature: Screen Functions test - _fn_put_digit

  This tests Atari screen function _fn_put_digit to place a digit within the display area

  Scenario: Running _fn_put_digit puts a digit in the given location
    Given atari application test setup
      And I add atari/screen src file "fn_put_digit.s"
      And I add atari/screen src file "fn_get_scrloc.s"
      And I add atari/screen src file "fn_screen_mem.s"
      And I add file for compiling "features/atari/screen/test_fn_put_digit.s"
      And I create and load application
      And I write memory at t_x with 1
      And I write memory at t_y with 0
      And I write memory at t_d with 8
      And I execute the procedure at _init for no more than 50 instructions
    
     # The border is made up of 2 chars: <inverse space> + <space>
     # so x=0 is 3rd character, x=1 is fourth character
     Then screen memory at m_l1 contains ascii
     """
     {inv} {inv}  8                                   {inv} {inv}
     """