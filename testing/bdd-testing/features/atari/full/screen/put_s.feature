Feature: Screen Functions test - _put_s

  This tests Atari screen function _put_s to place a string within the display area

  Scenario: Running _put_s puts a string that fits on a line without cropping at border
    Given atari application test setup
      And I add atari src file "full/screen/put_s.s"
      And I add atari src file "full/screen/clr_scr.s"
      And I add atari src file "full/screen/get_scrloc.s"
      And I add atari src file "full/screen/scr_data.s"
      And I add atari src file "common/screen/ascii_to_code.s"
      And I add file for compiling "features/test-setup/test-apps/test_bbw.s"
      And I create and load atari application
      And I write memory at t_b1 with 0
      And I write memory at t_b2 with 0
      And I write word at t_w3 with hex $a123
      And I write word at t_fn with address _put_s
      And I write string "this string fits!" as ascii to memory address $a123
      # draw borders so we can easily detect strings at edges
      And I execute the procedure at _clr_scr_all until return
      And I execute the procedure at _init for no more than 375 instructions
      And I print memory from m_l1 to m_l1+$78
    
     Then screen memory at m_l1 contains ascii
     """
     {^}ythis string fits!                     {inv}{^}y{inv}
     """

  Scenario: Running _put_s puts a string but crops it at the border
    Given atari application test setup
      And I add atari src file "full/screen/put_s.s"
      And I add atari src file "full/screen/clr_scr.s"
      And I add atari src file "full/screen/get_scrloc.s"
      And I add atari src file "full/screen/scr_data.s"
      And I add atari src file "common/screen/ascii_to_code.s"
      And I add file for compiling "features/test-setup/test-apps/test_bbw.s"
      And I create and load atari application
      And I write memory at t_b1 with 30
      And I write memory at t_b2 with 0
      And I write word at t_w3 with hex $a123
      And I write word at t_fn with address _put_s
      And I write string "this does not" as ascii to memory address $a123
      # draw borders so we can easily detect strings at edges
      And I execute the procedure at _clr_scr_all until return
      And I execute the procedure at _init for no more than 375 instructions
      And I print memory from m_l1 to m_l1+$78
    
     Then screen memory at m_l1 contains ascii
     """
     {^}y                              this doe{inv}{^}y{inv}
     """
