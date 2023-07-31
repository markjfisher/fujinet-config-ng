Feature: IO library test - _fn_io_boot

  This tests Atari _fn_io_boot is a NO-OP

  Scenario: execute _fn_io_boot does nothing
    Given atari simple test setup
      And I add file for compiling "../../src/atari/fn_io_boot.s"
      And I create and load simple application
      And I execute the procedure at _fn_io_boot for no more than 1 instructions
