Feature: IO library test - io_mount_host_slot

  This tests Atari io_mount_host_slot

  ##############################################################################################################
  Scenario Outline: execute io_mount_host_slot
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_get_host_slots.s"
      And I add file for compiling "../../src/atari/io_mount_host_slot.s"
      And I add file for compiling "../../src/atari/io_siov.s"
      And I add file for compiling "../../src/atari/io_copy_dcb.s"
      And I add file for compiling "features/atari/siov-stubs/siov-simple.s"
      And I create and load simple application
      And I write memory at $80 with $00
      And I set register A to <slot>
      And I write memory at io_hostslots+32*<slot> with 1
     When I execute the procedure at io_mount_host_slot for no more than 250 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $f9
     # rare to see 00 in DSTATS
     And I expect to see DSTATS equal $00
     And I expect to see DBYTLO equal $00
     And I expect to see DBYTHI equal $00
     And I expect to see DAUX1 equal <slot>
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal $00
     And I expect to see DBUFHI equal $00

     # verify SIOV was called
     And I expect to see $80 equal 1

    Examples:
    | slot |
    | 0    |
    | 1    |
    | 2    |

  ##############################################################################################################
  Scenario Outline: execute io_mount_host_slot does not run SIOV if first byte is 0
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_get_host_slots.s"
      And I add file for compiling "../../src/atari/io_mount_host_slot.s"
      And I add file for compiling "../../src/atari/io_siov.s"
      And I add file for compiling "../../src/atari/io_copy_dcb.s"
      And I add file for compiling "features/atari/siov-stubs/siov-simple.s"
      And I create and load simple application
      And I write memory at $80 with $ff
      And I set register A to <slot>
      And I write memory at io_hostslots+32*<slot> with 0
     When I execute the procedure at io_mount_host_slot for no more than 50 instructions

     # verify SIOV was NOT called
     And I expect to see $80 equal $ff

    Examples:
    | slot |
    | 0    |
    | 1    |
    | 2    |