Feature: IO library test - fn_io_update_devices_enabled

  This tests FN-IO fn_io_update_devices_enabled is a NO-OP

  Scenario: execute _fn_io_update_devices_enabled
    Given fn-io simple test setup
      And I add libs src file "fn_io/fn_io_update_devices_enabled.s"
      And I create and load simple application
      And I execute the procedure at _fn_io_update_devices_enabled for no more than 1 instructions