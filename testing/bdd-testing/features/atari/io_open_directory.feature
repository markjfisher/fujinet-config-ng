Feature: IO library test - io_open_directory

  This tests Atari io_open_directory

  ##############################################################################################################
  Scenario: execute io_open_directory with filter and path
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_open_directory.s"
      And I add file for compiling "../../src/atari/io_mem_io_buffer.s"
      And I add file for compiling "../../src/atari/io_siov.s"
      And I add file for compiling "../../src/atari/io_copy_dcb.s"
      And I add file for compiling "../../src/stdlib/strncpy.s"
      And I add file for compiling "../../src/stdlib/strncat.s"
      And I add file for compiling "features/atari/siov-stubs/siov-simple.s"
      And I create and load simple application
      And I write memory at $80 with $ff
      And I set register A to 3
      And I write string "/p/" as ascii to memory address dir_path
      And I write string "f1" as ascii to memory address dir_filter
     When I execute the procedure at io_open_directory for no more than 2170 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $f7
     And I expect to see DSTATS equal $80
     And I expect to see DBYTLO equal $00
     And I expect to see DBYTHI equal $01
     And I expect to see DAUX1 equal 3
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo(io_buffer)
     And I expect to see DBUFHI equal hi(io_buffer)
     And I print ascii from io_buffer to io_buffer+10

    When I hex+ dump ascii between io_buffer and io_buffer+32
    # /p/f1 + <00> nul byte
    Then property "test.BDD6502.lastHexDump" must contain string ": 2f 70 2f 66 31 00"
    Then property "test.BDD6502.lastHexDump" must contain string "/p/f1"

    # check SIOV was called
    Then I expect to see $80 equal $01

  ##############################################################################################################
  Scenario: execute io_open_directory with path only short circuits copying
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_open_directory.s"
      And I add file for compiling "../../src/atari/io_mem_io_buffer.s"
      And I add file for compiling "../../src/atari/io_siov.s"
      And I add file for compiling "../../src/atari/io_copy_dcb.s"
      And I add file for compiling "../../src/stdlib/strncpy.s"
      And I add file for compiling "../../src/stdlib/strncat.s"
      And I add file for compiling "features/atari/siov-stubs/siov-simple.s"
      And I create and load simple application
      And I write memory at $80 with $ff
      And I set register A to 4
      And I write string "/path/" as ascii to memory address dir_path
      And I write memory at dir_filter with $00
     When I execute the procedure at io_open_directory for no more than 70 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $f7
     And I expect to see DSTATS equal $80
     And I expect to see DBYTLO equal $00
     And I expect to see DBYTHI equal $01
     And I expect to see DAUX1 equal 4
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo(dir_path)
     And I expect to see DBUFHI equal hi(dir_path)
     And I print ascii from dir_path to dir_path+10

    When I hex+ dump ascii between dir_path and dir_path+32
    # /path/ + <00> nul byte
    Then property "test.BDD6502.lastHexDump" must contain string "/path/"
    Then property "test.BDD6502.lastHexDump" must contain string ": 2f 70 61 74 68 2f 00 00"

    # check SIOV was called
    Then I expect to see $80 equal $01