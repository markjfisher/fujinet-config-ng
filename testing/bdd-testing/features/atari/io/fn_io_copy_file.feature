Feature: IO library test - _fn_io_copy_file

  This tests Atari _fn_io_copy_file

  Scenario: execute _fn_io_copy_file
    Given atari application test setup
      And I add common io files
      And I add atari src file "io/fn_io_copy_file.s"
      And I add file for compiling "features/atari/io/test-apps/test_fn_io_copy_file.s"
      And I add file for compiling "features/atari/io/siov-stubs/siov-simple.s"
      And I create and load application
      And I write memory at $80 with $ff
      And I write memory at t_src with $01
      And I write memory at t_dst with $02
     When I execute the procedure at _init for no more than 100 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $fe
     And I expect to see DCOMND equal $d8
     And I expect to see DSTATS equal $80
     And I expect to see DBYTLO equal $00
     And I expect to see DBYTHI equal $01
     # src/dst are incremented by 1 for FN call
     And I expect to see DAUX1 equal $02
     And I expect to see DAUX2 equal $03
     And I expect to see DBUFLO equal lo(fn_io_buffer)
     And I expect to see DBUFHI equal hi(fn_io_buffer)

    # check SIOV was called
    Then I expect to see $80 equal $01