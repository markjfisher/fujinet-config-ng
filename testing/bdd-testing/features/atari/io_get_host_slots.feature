Feature: IO library test - io_get_host_slots

  This tests Atari io_get_host_slots

  ##############################################################################################################
  Scenario: execute io_get_host_slots
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_get_host_slots.s"
      And I add file for compiling "../../src/atari/io_siov.s"
      And I add file for compiling "../../src/atari/io_copy_dcb.s"
      And I add file for compiling "../../src/atari/io_mem.s"
      And I add file for compiling "features/atari/siov-stubs/siov-simple.s"
      And I create and load simple application
      And I write memory at $80 with $00

     When I execute the procedure at io_get_host_slots for no more than 250 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $f4
     And I expect to see DSTATS equal $40
     And I expect to see DBYTLO equal $00
     And I expect to see DBYTHI equal $01
     And I expect to see DAUX1 equal $00
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo(io_hostslots)
     And I expect to see DBUFHI equal hi(io_hostslots)

     # verify SIOV was called
     And I expect to see $80 equal 1
