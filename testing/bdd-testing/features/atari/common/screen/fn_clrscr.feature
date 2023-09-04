Feature: Screen Functions test - _clr_scr_all

  This tests Atari screen function _clr_scr_all to clear the bordered area of screen display

  Scenario: Running _clr_scr_all clears the bordered screen
    Given atari application test setup
      And I add atari src file "common/screen/clr_scr.s"
      And I add atari src file "common/screen/get_scrloc.s"
      And I add atari src file "common/screen/fn_screen_mem.s"
      And I add file for compiling "features/atari/common/screen/test_clr_scr_all.s"
      And I create and load application
      And I execute the procedure at _init for no more than 3800 instructions
    
     Then screen memory at m_l1 contains ascii
     """
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}\
     {inv} {inv}                                      {inv} {inv}
     """