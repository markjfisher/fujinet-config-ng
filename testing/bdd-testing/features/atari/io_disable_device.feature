Feature: IO library test - io_disable_device

  This tests Atari io_disable_device

  ##############################################################################################################
  Scenario: execute io_disable_device should set A
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_disable_device.s"
      And I create and load simple application
      And I execute the procedure at io_disable_device for no more than 1 instructions
