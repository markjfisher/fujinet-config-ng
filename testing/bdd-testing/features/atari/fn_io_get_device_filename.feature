Feature: IO library test - _fn_io_get_device_filename

  This tests Atari _fn_io_get_device_filename

  Scenario Outline: execute _fn_io_get_device_filename
    Given atari simple test setup
      And I add common io files
      And I add file for compiling "../../src/atari/fn_io_get_device_filename.s"
      And I add file for compiling "features/atari/siov-stubs/siov-simple.s"
      And I create and load simple application
      And I write memory at $80 with $00

     # set the slot_offset
     When I set register A to <slot_offset>
      And I execute the procedure at _fn_io_get_device_filename for no more than 70 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $da
     And I expect to see DSTATS equal $40
     And I expect to see DBYTLO equal $00
     And I expect to see DBYTHI equal $01
     And I expect to see DAUX1 equal <slot_offset>
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo(fn_io_buffer)
     And I expect to see DBUFHI equal hi(fn_io_buffer)

     # verify SIOV was called
     And I expect to see $80 equal 1
  Examples:
  | slot_offset | comment           |
  | $07         | normal slots 0-7  |
  | $1a         | cas slot          |