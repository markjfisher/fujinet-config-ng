Feature: IO library test - fn_io_build_directory

  This tests FN-IO fn_io_build_directory is a NO-OP

  Scenario: execute _fn_io_build_directory
    Given fn-io simple test setup
      And I add libs src file "fn_io/fn_io_build_directory.s"
      And I create and load simple application
      And I execute the procedure at _fn_io_build_directory for no more than 1 instructions
