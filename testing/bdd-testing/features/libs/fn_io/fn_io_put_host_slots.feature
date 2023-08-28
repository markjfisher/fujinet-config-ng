Feature: IO library test - fn_io_put_host_slots

  This tests FN-IO fn_io_put_host_slots

  Scenario: execute _fn_io_put_host_slots
    Given fn-io simple test setup
      And I add common io files
      And I add libs src file "fn_io/fn_io_get_host_slots.s"
      And I add libs src file "fn_io/fn_io_put_host_slots.s"
      And I add file for compiling "features/test-setup/stubs/sio-simple.s"
      And I create and load simple application
      And I write memory at $80 with $00
      And I set register A to $00
      And I set register X to $a0

     When I execute the procedure at _fn_io_put_host_slots for no more than 75 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $f3
     And I expect to see DSTATS equal $80
     And I expect to see DBYTLO equal $00
     And I expect to see DBYTHI equal $01
     And I expect to see DAUX1 equal $00
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo($a000)
     And I expect to see DBUFHI equal hi($a000)

     # verify SIOV was called
     And I expect to see $80 equal 1
