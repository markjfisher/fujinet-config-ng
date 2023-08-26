Feature: IO library test - fn_io_enable_device

  This tests FN-IO fn_io_enable_device is a NO-OP

  Scenario: execute _fn_io_enable_device
    Given fn-io simple test setup
      And I add libs src file "fn_io/fn_io_enable_device.s"
      And I create and load simple application
      And I execute the procedure at _fn_io_enable_device for no more than 1 instructions
