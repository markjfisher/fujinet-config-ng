Feature: IO library test

  This tests Atari io.asm library

  Scenario Outline: execute io_error should set A
    Given basic setup test "io_error"
    And I mads-compile "io" from "../../src/libs/atari/io.asm"
    And I build and load the application "test_io" from "features/atari/test_io.asm"

    When I write memory at dstats with <init>
     And I execute the procedure at test_io_error for no more than 50 instructions

    Then I expect register A equal <A>

    # A should contain (init & 0x80) as simplest test if bit 7 is set.
    Examples:
      | init |  A   |
      | 0x00 | 0x00 |
      | 0x01 | 0x00 |
      | 0x7f | 0x00 |
      | 0x80 | 0x80 |
      | 0x81 | 0x80 |
      | 0xff | 0x80 |

  Scenario: execute io_init should setup some system values
    Given basic setup test "io_init"
    And I mads-compile "io" from "../../src/libs/atari/io.asm"
    And I build and load the application "test_io" from "features/atari/test_io.asm"

    When I execute the procedure at test_io_init for no more than 50 instructions

    Then I expect to see noclik equal $ff
     And I expect to see shflok equal $00
     And I expect to see coldst equal $01
     And I expect to see sdmctl equal $00

  Scenario Outline: execute io_get_wifi_enabled return if wifi is enabled
    Given basic setup test "io_get_wifi_enabled"
      And I mads-compile "io" from "../../src/libs/atari/io.asm"
      And I build and load the application "test_io" from "features/atari/test_io.asm"
      And I create file "build/tests/sio-patch.asm" with
      """
      ; stub SIOV
        icl "../../../../src/libs/atari/inc/os.inc"

        org SIOV
        ; Emulate SIOV call by injecting test value t_v into pointer in DBUF
        mwa DBUFLO $80
        ldy #0
        mva t_v ($80),y
        rts

      ; an address for the test to write to. this is the stubbed value that will be written to by pointer at DBUF
      t_v dta 0

    """
    And I patch machine with file "sio-patch"

    When I write memory at t_v with <sio_ret>
     And I execute the procedure at test_io_get_wifi_enabled for no more than 50 instructions

    # check the DCB values were set correctly
    Then I expect to see ddevic equal $70
     And I expect to see dunit equal $01
     And I expect to see dtimlo equal $0f
     And I expect to see dcomnd equal $ea
     And I expect to see dstats equal $40
     And I expect to see dbytlo equal $01
     And I expect to see dbythi equal $00

    # Test status flags
    And I expect register state <ST>
    And I expect register A equal <A>

    # Z flag should be set if wifi not enabled. clear otherwise. Need to hijack siov to  set wifi value
    Examples:
    | sio_ret |  ST   |  A  | Comment        |
    | 0       |  Z:1  |  0  | Not enabled    |
    | 1       |  Z:0  |  1  | Enabled        |
    | 0x80    |  Z:1  |  0  | Not enabled    |
    | 0xff    |  Z:1  |  0  | Not enabled    |

  Scenario Outline: execute io_get_wifi_status returns status of wifi in A
    Given basic setup test "io_get_wifi_status"
      And I mads-compile "io" from "../../src/libs/atari/io.asm"
      And I build and load the application "test_io" from "features/atari/test_io.asm"
      And I create file "build/tests/sio-patch.asm" with
      """
      ; stub SIOV
        icl "../../../../src/libs/atari/inc/os.inc"

        org SIOV
        ; Emulate SIOV call by injecting test value t_v into pointer in DBUF
        mwa DBUFLO $80
        ldy #0
        mva t_v ($80),y
        rts

      ; an address for the test to write to. this is the stubbed value that will be written to by pointer at DBUF
      t_v dta 0

    """
    And I patch machine with file "sio-patch"

    When I write memory at t_v with <sio_ret>
     And I execute the procedure at io_get_wifi_status for no more than 50 instructions

    # check the DCB values were set correctly
    Then I expect to see ddevic equal $70
     And I expect to see dunit equal $01
     And I expect to see dtimlo equal $0f
     And I expect to see dcomnd equal $fa
     And I expect to see dstats equal $40
     And I expect to see dbytlo equal $01
     And I expect to see dbythi equal $00

    # Test status flags
    And I expect register A equal <A>

    # The injected value should go straight into the A reg
    Examples:
    | sio_ret |  A  | Comment               |
    | 1       |  1  | No SSID Available     |
    | 3       |  3  | Connection Successful |
    | 4       |  4  | Connect Failed        |
    | 5       |  5  | Connection lost       |
