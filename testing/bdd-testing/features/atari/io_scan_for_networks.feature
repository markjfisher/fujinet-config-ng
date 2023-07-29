Feature: IO library test - io_scan_for_networks

  This tests Atari io_scan_for_networks

  ##############################################################################################################
  Scenario Outline: execute io_scan_for_networks
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_scan_for_networks.s"
      And I add file for compiling "../../src/atari/io_siov.s"
      And I add file for compiling "../../src/atari/io_copy_dcb.s"
      And I add file for compiling "features/atari/siov-stubs/siov-dbuflo1.s"
      And I create and load simple application
      And I write memory at $80 with $00

     When I set register A to $aa
      And I write memory at t_v with <networks>
      And I execute the procedure at io_scan_for_networks for no more than 65 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $fd
     And I expect to see DSTATS equal $40
     And I expect to see DBYTLO equal $04
     And I expect to see DBYTHI equal $00
     And I expect to see DAUX1 equal $00
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo(io_scan)
     And I expect to see DBUFHI equal hi(io_scan)

     And I expect register A equal <networks>

    Examples:
    | networks |
    | 0        |
    | 1        |
    | 10       |