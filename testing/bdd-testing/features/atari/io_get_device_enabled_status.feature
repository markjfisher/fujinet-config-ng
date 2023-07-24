Feature: IO library test - io_get_device_enabled_status

  This tests Atari io_get_device_enabled_status

  ##############################################################################################################
  Scenario: execute io_get_device_enabled_status should set A
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_get_device_enabled_status.s"
      And I create and load simple application
      And I set register A to $aa

     When I execute the procedure at io_get_device_enabled_status for no more than 10 instructions

     Then I expect register A equal 1