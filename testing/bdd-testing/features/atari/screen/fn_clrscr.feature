Feature: Screen Functions test - _fn_clrscr

  This tests Atari screen function _fn_clrscr to clear the bordered area of screen display

  Scenario: Running _fn_clrscr clears the bordered screen
    Given atari application test setup
      And I add atari/screen src file "fn_clrscr.s"
      And I add atari/screen src file "fn_get_scrloc.s"
      And I add atari/screen src file "fn_screen_mem.s"
      And I add file for compiling "features/atari/screen/test_fn_clrscr.s"
      And I create and load application
      And I execute the procedure at _init for no more than 2550 instructions
    
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