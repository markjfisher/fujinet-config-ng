Feature: Screen Functions test - get_scrloc

  This tests Atari screen function get_scrloc to get the location of x,y coordinate within border

  Scenario Outline: Running get_scrloc sets ptr4 to x/y location
    Given atari application test setup
      And I add atari src file "full/screen/get_scrloc.s"
      And I add atari src file "full/screen/scr_data.s"
      And I add file for compiling "features/test-setup/test-apps/test_0.s"
      And I create and load atari application
      And I set register X to <x>
      And I set register Y to <y>
      And I write word at t_fn with address get_scrloc
      And I execute the procedure at _main for no more than 30 instructions
    
     Then I expect to see ptr4 equal lo(<loc>)
     Then I expect to see ptr4+1 equal hi(<loc>)

   # border has 1 chars on L and R edges (only L matters), so we add 1 to each location
   Examples:
   | x | y | loc     |
   | 0 | 0 | m_l1+1  |
   | 1 | 0 | m_l1+2  |
   | 0 | 1 | m_l1+41 |
   | 1 | 1 | m_l1+42 |