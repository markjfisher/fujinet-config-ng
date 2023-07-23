Feature: IO library test - io_init

  This tests Atari io_init

  ##############################################################################################################
  Scenario: execute io_error should set A
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_init.s"
      And I create and load simple application

     When I execute the procedure at io_init for no more than 30 instructions

     Then I expect to see NOCLIK equal $ff
      And I expect to see SHFLOK equal $00
      And I expect to see COLDST equal $01
      And I expect to see SDMCTL equal $00