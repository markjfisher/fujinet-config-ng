Feature: IO library test - fn_io_get_device_slots

  This tests FN-IO fn_io_get_device_slots

  Scenario: execute _fn_io_get_device_slots
    Given fn-io simple test setup
      And I add common io files
      And I add libs src file "fn_io/fn_io_get_device_slots.s"
      And I add file for compiling "features/test-setup/stubs/sio-simple.s"
      And I create and load simple application
      And I write memory at $80 with $00

     # set the slot_offset
     When I execute the procedure at _fn_io_get_device_slots for no more than 70 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $f2
     And I expect to see DSTATS equal $40
     # $130 = 8 * 38
     And I expect to see DBYTLO equal $30
     And I expect to see DBYTHI equal $01
     And I expect to see DAUX1 equal $00
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo(fn_io_deviceslots)
     And I expect to see DBUFHI equal hi(fn_io_deviceslots)

     # verify SIOV was called
     And I expect to see $80 equal 1