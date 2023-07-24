Feature: IO library test - io_update_devices_enabled

  This tests Atari io_get_device_enabled_status

  ##############################################################################################################
  Scenario: execute io_update_devices_enabled should set A
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_update_devices_enabled.s"
      And I create and load simple application
      And I execute the procedure at io_update_devices_enabled for no more than 1 instructions
