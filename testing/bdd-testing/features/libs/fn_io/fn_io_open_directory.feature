Feature: IO library test - fn_io_open_directory

  This tests FN-IO fn_io_open_directory

  Scenario: execute _fn_io_open_directory with filter and path
    Given fn-io application test setup
      And I add common io files
      And I add libs src file "fn_io/fn_io_open_directory.s"
      And I add file for compiling "features/test-setup/test-apps/test_fn_io_open_directory.s"
      And I add file for compiling "features/test-setup/stubs/sio-simple.s"
      And I create and load application
      And I write memory at $80 with $ff
      And I write memory at t_buffer with $00
      And I write memory at t_buffer+1 with $A0
      And I write memory at t_host_slot with $03
     When I execute the procedure at _init for no more than 100 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $f7
     And I expect to see DSTATS equal $80
     And I expect to see DBYTLO equal $00
     And I expect to see DBYTHI equal $01
     And I expect to see DAUX1 equal 3
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo($a000)
     And I expect to see DBUFHI equal hi($a000)

    # check SIOV was called
    Then I expect to see $80 equal $01
