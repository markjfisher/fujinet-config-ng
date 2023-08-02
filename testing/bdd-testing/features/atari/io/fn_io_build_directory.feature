Feature: IO library test - _fn_io_build_directory

  This tests Atari _fn_io_build_directory is a NO-OP

  Scenario: execute _fn_io_build_directory
    Given atari simple test setup
      And I add atari src file "io/fn_io_build_directory.s"
      And I create and load simple application
      And I execute the procedure at _fn_io_build_directory for no more than 1 instructions
