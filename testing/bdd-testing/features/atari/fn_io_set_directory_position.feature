Feature: IO library test - _fn_io_set_directory_position

  This tests Atari _fn_io_set_directory_position

  Scenario: execute _fn_io_set_directory_position
    Given atari application test setup
      And I add common io files
      And I add file for compiling "../../src/atari/fn_io_set_directory_position.s"
      And I add file for compiling "features/atari/test-apps/test_fn_io_set_directory_position.s"
      And I add file for compiling "features/atari/siov-stubs/siov-simple.s"
      And I create and load application
      And I write memory at $80 with $ff
      And I write memory at t_pos with $20
      And I write memory at t_pos+1 with $00
     When I execute the procedure at _init for no more than 100 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $e4
     And I expect to see DSTATS equal $00
     And I expect to see DBYTLO equal $00
     And I expect to see DBYTHI equal $00
     And I expect to see DAUX1 equal $20
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal $00
     And I expect to see DBUFHI equal $00

    # check SIOV was called
    Then I expect to see $80 equal $01
