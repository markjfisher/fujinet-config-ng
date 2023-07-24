Feature: IO library test - io_device_slot_to_device

  This tests Atari io_device_slot_to_device

  ##############################################################################################################
  Scenario: execute io_device_slot_to_device should set A
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_device_slot_to_device.s"
      And I create and load simple application
      And I execute the procedure at io_device_slot_to_device for no more than 1 instructions
