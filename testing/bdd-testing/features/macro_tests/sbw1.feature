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
     When I execute the procedure at test_sbw1_word_imm_dec for no more than 11 instructions
     Then I expect to see t_t1 equal lo($1141)
      And I expect to see t_t1+1 equal hi($1141)

     ########################################################
     # WORD, #WORD, WORD
     When I execute the procedure at test_sbw1_word_byte for no more than 10 instructions
     Then I expect to see t_t1 equal lo($1223)
      And I expect to see t_t1+1 equal hi($1223)

     ########################################################
     # WORD, WORD, WORD
     When I execute the procedure at test_sbw1_word_byte_dec for no more than 11 instructions
     Then I expect to see t_t1 equal lo($1141)
      And I expect to see t_t1+1 equal hi($1141)

     ########################################################
     # WORD, A
     When I set register A to $11
      And I write memory at t_t1 with $34
      And I write memory at t_t1+1 with $12
      And I execute the procedure at test_sbw1_word_a for no more than 10 instructions
     Then I expect to see t_t1 equal lo($1223)
      And I expect to see t_t1+1 equal hi($1223)

     ########################################################
     # WORD, A + dec
     When I set register A to $f3
      And I write memory at t_t1 with $34
      And I write memory at t_t1+1 with $12
      And I execute the procedure at test_sbw1_word_a for no more than 12 instructions
     Then I expect to see t_t1 equal lo($1141)
      And I expect to see t_t1+1 equal hi($1141)

     ########################################################
     # WORD, A
     When I set register A to $34
      And I write memory at t_t1 with $34
      And I write memory at t_t1+1 with $00
      And I execute the procedure at test_sbw1_word_a for no more than 9 instructions
     Then I expect to see t_t1 equal lo($0000)
      And I expect to see t_t1+1 equal hi($0000)

     ########################################################
     # WORD, A + dec
     When I set register A to $35
      And I write memory at t_t1 with $34
      And I write memory at t_t1+1 with $00
      And I execute the procedure at test_sbw1_word_a for no more than 12 instructions
     Then I expect to see t_t1 equal lo($ffff)
      And I expect to see t_t1+1 equal hi($ffff)

