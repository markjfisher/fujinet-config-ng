Feature: MACRO tests - adw1

  This tests adw1 "add word to byte" macro.
  The instruction count is exact to ensure the more efficient methods are used

  Scenario: adw1 adds words
    Given atari simple test setup
      And I add file for compiling "features/macro_tests/test_adw1.s"
      And I create and load simple atari application

     ########################################################
     # WORD, #byte
     When I execute the procedure at test_adw1_word_imm for no more than 10 instructions     
     Then I expect to see t_t1 equal lo($1245)
      And I expect to see t_t1+1 equal hi($1245)

     ########################################################
     # WORD, #byte + inc
     When I execute the procedure at test_adw1_word_imm_inc for no more than 11 instructions
     Then I expect to see t_t1 equal lo($1327)
      And I expect to see t_t1+1 equal hi($1327)

     ########################################################
     # WORD, byte
     When I execute the procedure at test_adw1_word_byte for no more than 10 instructions
     Then I expect to see t_t1 equal lo($1245)
      And I expect to see t_t1+1 equal hi($1245)

     ########################################################
     # WORD, byte + inc
     When I execute the procedure at test_adw1_word_byte_inc for no more than 11 instructions
     Then I expect to see t_t1 equal lo($1327)
      And I expect to see t_t1+1 equal hi($1327)

     ########################################################
     # WORD, A
     When I set register A to $11
      And I write memory at t_t1 with $34
      And I write memory at t_t1+1 with $12
      And I execute the procedure at test_adw1_word_a for no more than 5 instructions
     Then I expect to see t_t1 equal lo($1245)
      And I expect to see t_t1+1 equal hi($1245)

     ########################################################
     # WORD, A + inc
     When I set register A to $f3
      And I write memory at t_t1 with $34
      And I write memory at t_t1+1 with $12
      And I execute the procedure at test_adw1_word_a_inc for no more than 6 instructions
     Then I expect to see t_t1 equal lo($1327)
      And I expect to see t_t1+1 equal hi($1327)

