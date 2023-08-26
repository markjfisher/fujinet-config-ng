Feature: IO library test - fn_io_read_directory

  This tests FN-IO fn_io_read_directory

  Scenario: execute _fn_io_read_directory
    Given fn-io application test setup
      And I add common io files
      And I add libs src file "fn_io/fn_io_read_directory.s"
      And I add file for compiling "features/test-setup/test-apps/test_fn_io_read_directory.s"
      And I add file for compiling "features/test-setup/stubs/sio-simple.s"
      And I create and load application
      And I write memory at $80 with $ff
      And I write memory at t_maxlen with $20
      And I write memory at t_aux2 with $80
      And I write memory at fn_io_buffer with $aa
     When I execute the procedure at _init for no more than 1000 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $f6
     And I expect to see DSTATS equal $40
     And I expect to see DBYTLO equal $20
     And I expect to see DBYTHI equal $00
     And I expect to see DAUX1 equal $20
     And I expect to see DAUX2 equal $80
     And I expect to see DBUFLO equal lo(fn_io_buffer)
     And I expect to see DBUFHI equal hi(fn_io_buffer)
     And I expect register A equal lo(fn_io_buffer)
     And I expect register X equal hi(fn_io_buffer)

    # check SIOV was called
    Then I expect to see $80 equal $01
