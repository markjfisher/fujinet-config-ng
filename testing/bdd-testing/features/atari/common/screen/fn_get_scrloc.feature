Feature: Screen Functions test - get_scrloc

  This tests Atari screen function get_scrloc to get the location of x,y coordinate within border

  Scenario Outline: Running get_scrloc sets ptr4 to x/y location
    Given atari application test setup
      And I add atari src file "common/screen/get_scrloc.s"
      And I add atari src file "common/screen/fn_screen_mem.s"
      And I add file for compiling "features/atari/common/screen/test_get_scrloc.s"
      And I create and load application
      And I write memory at t_x with <x>
      And I write memory at t_y with <y>
      And I execute the procedure at _init for no more than 50 instructions
    
     Then I expect to see ptr4 equal lo(<loc>)
     Then I expect to see ptr4+1 equal hi(<loc>)

   # border has 2 chars on L and R edges (only L matters), so we add 2 to each location
   Examples:
   | x | y | loc     |
   | 0 | 0 | m_l1+2  |
   | 1 | 0 | m_l1+3  |
   | 0 | 1 | m_l1+42 |
   | 1 | 1 | m_l1+43 |