Feature: MACRO tests - sbw1

  This tests sbw1 "subtract byte from word" macro.
  The instruction count is exact to ensure the more efficient methods are used

  Scenario: sbw1 subtracts byte from word
    Given atari simple test setup
      And I add file for compiling "features/macro_tests/test_sbw1.s"
      And I create and load simple application

     ########################################################
     # WORD, #WORD
     When I execute the procedure at test_sbw1_word_imm for no more than 10 instructions     
     Then I expect to see t_t1 equal lo($1223)
      And I expect to see t_t1+1 equal hi($1223)

     ########################################################
     # WORD, WORD
     When I execute the procedure at test_sbw1_word_imm_inc for no more than 11 instructions
     Then I expect to see t_t2 equal lo($1141)
      And I expect to see t_t2+1 equal hi($1141)

     ########################################################
     # WORD, #WORD, WORD
     When I execute the procedure at test_sbw1_word_byte for no more than 10 instructions
     Then I expect to see t_t3 equal lo($1223)
      And I expect to see t_t3+1 equal hi($1223)

     ########################################################
     # WORD, WORD, WORD
     When I execute the procedure at test_sbw1_word_byte_inc for no more than 11 instructions
     Then I expect to see t_t4 equal lo($1141)
      And I expect to see t_t4+1 equal hi($1141)
