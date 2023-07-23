Feature: IO library test - io_get_wifi_status

  This tests Atari io_get_wifi_status

  ##############################################################################################################
  Scenario Outline: execute io_get_wifi_status
    Given atari simple test setup
      And I add file for compiling "../../src/atari/io_get_wifi_status.s"
      And I add file for compiling "../../src/atari/io_siov.s"
      And I add file for compiling "../../src/atari/io_copy_dcb.s"
      And I stub locations for imports in "../../src/atari/io_copy_dcb.s" except for "wifi_status"
      And I create file "build/tests/sio-patch.s" with
      """
      ; stub SIOV
        .include    "atari.inc"
        .include    "../../../../src/inc/macros.inc"
        .export     t_v

        .segment "SIOSEG"
        .org SIOV
        ; Emulate SIOV call by injecting test value t_v into pointer in DBUF
        mwa DBUFLO, $80

        ldy #0
        mva t_v, {($80), y}
        rts

      ; an address for the test to write to. this is the stubbed value that will be written to by pointer at DBUF
      t_v: .byte 0

    """

      And I add file for compiling "build/tests/sio-patch.s"
      And I create and load simple application

    When I write memory at t_v with <sio_ret>
     And I execute the procedure at io_get_wifi_status for no more than 80 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $fa
     And I expect to see DSTATS equal $40
     And I expect to see DBYTLO equal $01
     And I expect to see DBYTHI equal $00
     And I expect to see DAUX1 equal $00
     And I expect to see DAUX2 equal $00

    # Test status flags
    And I expect register A equal <A>

    # The injected value should go straight into the A reg
    Examples:
    | sio_ret |  A  | Comment               |
    | 1       |  1  | No SSID Available     |
    | 3       |  3  | Connection Successful |
    | 4       |  4  | Connect Failed        |
    | 5       |  5  | Connection lost       |