Feature: MACRO tests - adw

  This tests adw "add word" macro.

  Scenario: adw adds word values
    Given atari simple test setup
      And I add file for compiling "features/macro_tests/test_adw.s"
      And I create and load simple application

     When I execute the procedure at test_adw for no more than 200 instructions
     
     Then I expect to see t_t1 equal lo($2345)
      And I expect to see t_t1+1 equal hi($2345)
      And I expect to see t_t2 equal lo($b247)
      And I expect to see t_t2+1 equal hi($b247)
      And I expect to see t_t3 equal lo($3456)
      And I expect to see t_t3+1 equal hi($3456)
      And I expect to see t_t4 equal lo($b124)
      And I expect to see t_t4+1 equal hi($b124)
