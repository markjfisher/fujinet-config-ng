Feature: IO library test - _fn_io_update_devices_enabled

  This tests Atari _fn_io_get_device_enabled_status

  Scenario: execute _fn_io_update_devices_enabled should set A
    Given atari simple test setup
      And I add file for compiling "../../src/atari/fn_io_update_devices_enabled.s"
      And I create and load simple application
      And I execute the procedure at _fn_io_update_devices_enabled for no more than 1 instructions
