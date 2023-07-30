Feature: IO library test - _fn_io_device_slot_to_device

  This tests Atari _fn_io_device_slot_to_device

  Scenario: execute _fn_io_device_slot_to_device should set A
    Given atari simple test setup
      And I add file for compiling "../../src/atari/fn_io_device_slot_to_device.s"
      And I create and load simple application
      And I execute the procedure at _fn_io_device_slot_to_device for no more than 1 instructions
