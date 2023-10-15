Feature: Screen Functions test - _clr_scr_all

  This tests Atari screen function _clr_scr_all to clear the bordered area of screen display

  Scenario: Running _clr_scr_all clears the bordered screen
    Given atari application test setup
      And I add atari src file "full/screen/clr_scr.s"
      And I add atari src file "full/screen/get_scrloc.s"
      And I add atari src file "full/screen/scr_data.s"
      And I add file for compiling "features/test-setup/test-apps/test_0.s"
      And I create and load atari application
      And I write word at t_fn with address _clr_scr_all
      And I execute the procedure at _init for no more than 3800 instructions
    
     Then screen memory at m_l1 contains ascii
     """
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}\
     {^}y                                      {inv}{^}y{inv}
     """