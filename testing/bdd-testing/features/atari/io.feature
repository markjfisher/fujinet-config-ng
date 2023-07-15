Feature: IO library test

  This tests Atari io.asm library

  ##############################################################################################################
  Scenario Outline: execute io_error should set A
    Given basic setup test "io_error"
    And I mads-compile "io" from "../../src/libs/atari/io.asm"
    And I build and load the application "test_io" from "features/atari/test_io.asm"

    When I write memory at dstats with <init>
     And I execute the procedure at io_error for no more than 50 instructions

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

    When I execute the procedure at io_init for no more than 50 instructions

    Then I expect to see noclik equal $ff
     And I expect to see shflok equal $00
     And I expect to see coldst equal $01
     And I expect to see sdmctl equal $00

  ##############################################################################################################
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
     And I execute the procedure at io_get_wifi_enabled for no more than 50 instructions

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

    # Z flag should be set if wifi not enabled. clear otherwise.
    Examples:
    | sio_ret |  ST   |  A  | Comment        |
    | 0       |  Z:1  |  0  | Not enabled    |
    | 1       |  Z:0  |  1  | Enabled        |
    | 0x80    |  Z:1  |  0  | Not enabled    |
    | 0xff    |  Z:1  |  0  | Not enabled    |

  ##############################################################################################################
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

  ##############################################################################################################
  Scenario: execute io_get_ssid returns pointer to NetConfig in A/X
    Given basic setup test "get ssid"
      And I mads-compile "io" from "../../src/libs/atari/io.asm"
      And I build and load the application "test_io" from "features/atari/test_io.asm"
      And I create file "build/tests/sio-patch.asm" with
      """
      ; stub SIOV
        icl "../../../../src/libs/atari/inc/os.inc"
        icl "../../../../src/libs/atari/inc/io.inc" ; for the NetConfig struct

        org SIOV
        mwa DBUFLO $80

        ; copy ssid/pass into netconfig buffer for test
        ; this is needed because of a struct bug with strings in MADS, so having to manually copy strings.
        ldy #8
        mva:rpl t_ssid,y nc+NetConfig.ssid,y-
        ldy #8
        mva:rpl t_pass,y nc+NetConfig.password,y-

        ; copy the netconfig to the caller's buffer.
        ldy #96
        mva:rpl nc,y ($80),y-
        rts

      t_ssid  dta d'yourssid'
      t_pass  dta d'password'

      nc dta NetConfig
    """
     And I patch machine with file "sio-patch"
     # And I print memory from siov to siov+192

    When I execute the procedure at io_get_ssid for no more than 1000 instructions

    # check the DCB values were set correctly
    Then I expect to see ddevic equal $70
     And I expect to see dunit equal $01
     And I expect to see dtimlo equal $0f
     And I expect to see dcomnd equal $fe
     And I expect to see dstats equal $40
     And I expect to see dbytlo equal 97
     And I expect to see dbythi equal $00

    # A/X contains L/H address of NetConfig created. Returned in property test.BDD6502.regsValue
    When I convert registers AX to address

    # test the ssid was copied into struct
     And I hex dump memory for 8 bytes from property "test.BDD6502.regsValue"
    Then property "test.BDD6502.lastHexDump" must contain string "yourssid"

    # test the password was copied into struct
    When I add 33 to property "test.BDD6502.regsValue"
     And I hex dump memory for 8 bytes from property "test.BDD6502.regsValue"
    Then property "test.BDD6502.lastHexDump" must contain string "password"

  ##############################################################################################################
  Scenario: execute io_set_ssid calls SIOV with correct data
    Given basic setup test "io_set_ssid"
      And I mads-compile "io" from "../../src/libs/atari/io.asm"
      And I build and load the application "test_io" from "features/atari/test_io.asm"
      And I create file "build/tests/sio-patch.asm" with
      """
      ; stub SIOV
        org $e459
        ; marker to show we called it
        mva #$01 $80
        rts
    """
     And I patch machine with file "sio-patch"
     And I set register A to $aa
     And I set register X to $bb
     And I write memory at $80 with $00

    When I execute the procedure at io_set_ssid for no more than 50 instructions

    # check the DCB values were set correctly
    Then I expect to see ddevic equal $70
     And I expect to see dunit equal $01
     And I expect to see dtimlo equal $0f
     And I expect to see dcomnd equal $fb
     And I expect to see dstats equal $80
     And I expect to see dbytlo equal 97
     And I expect to see dbythi equal $00
     And I expect to see daux1 equal $01
     # A/X are stored into the lo/hi locations
     And I expect to see dbuflo equal $aa
     And I expect to see dbufhi equal $bb
     
     # prove we called siov
     And I expect to see $80 equal $01

  ##############################################################################################################
  Scenario Outline: execute io_scan_for_networks puts number of networks into X
    Given basic setup test "io_scan_for_networks"
      And I mads-compile "io" from "../../src/libs/atari/io.asm"
      And I build and load the application "test_io" from "features/atari/test_io.asm"
      And I create file "build/tests/sio-patch.asm" with
      """
      ; stub SIOV
        icl "../../../../src/libs/atari/inc/os.inc"
        
        org SIOV
        ; buffer address in DBUF, copy t_v into first byte for network count
        mwa DBUFLO $80
        ldy #0
        mva t_v ($80),y
        rts

      ; location for test to write the number of networks into
      t_v dta 0

        rts
    """
     And I patch machine with file "sio-patch"
     And I set register A to $aa
     And I set register X to $bb
     And I write memory at $80 with $00

    When I write memory at t_v with <networks>
     And I execute the procedure at io_scan_for_networks for no more than 50 instructions

    # check the DCB values were set correctly
    Then I expect to see ddevic equal $70
     And I expect to see dunit equal $01
     And I expect to see dtimlo equal $0f
     And I expect to see dcomnd equal $fd
     And I expect to see dstats equal $40
     And I expect to see dbytlo equal 4
     And I expect to see dbythi equal $00
     And I expect to see daux1 equal $00

     # X contains count
     And I expect register X equal <networks>

    Examples:
    | networks |
    | 0        |
    | 1        |
    | 10       |     

  ##############################################################################################################
  Scenario: execute io_get_scan_result returns pointer to SSIDInfo in A/X
    Given basic setup test "io_get_scan_result"
      And I mads-compile "io" from "../../src/libs/atari/io.asm"
      And I build and load the application "test_io" from "features/atari/test_io.asm"
      And I create file "build/tests/sio-patch.asm" with
      """
      ; stub SIOV
        icl "../../../../src/libs/atari/inc/os.inc"
        icl "../../../../src/libs/atari/inc/io.inc" ; for the NetConfig struct

        org SIOV
        mwa DBUFLO $80  ; copy DBUF pointers into ZP

        ; copy test data into struct (TODO: remove when MADS bug fixed)
        ldy #8
        mva:rpl t_ssid,y info+SSIDInfo.ssid,y-
        mva     t_rssi   info+SSIDInfo.rssi

        ; copy the test ssidinfo to the caller's buffer.
        ldy #34
        mva:rpl info,y ($80),y-
        rts

      ; locations for test to set values
      t_ssid  dta d'ssidtime'
      t_rssi  dta $69

      ; location to store our stubbed return
      info    dta SSIDInfo
    """
     And I patch machine with file "sio-patch"
     And I print memory from siov to siov+192

    When I execute the procedure at io_get_scan_result for no more than 1000 instructions

    # check the DCB values were set correctly
    Then I expect to see ddevic equal $70
     And I expect to see dunit equal $01
     And I expect to see dtimlo equal $0f
     And I expect to see dcomnd equal $fc
     And I expect to see dstats equal $40
     And I expect to see dbytlo equal 34
     And I expect to see dbythi equal $00

    # Test the return values in A/X point to buffer with correct data.
    # A/X contains L/H address of SSIDInfo created. Returned in property test.BDD6502.regsValue
    When I convert registers AX to address

    # test the ssid was copied into struct
     And I hex dump memory for 8 bytes from property "test.BDD6502.regsValue"
    Then property "test.BDD6502.lastHexDump" must contain string "ssidtime"

    # test the rssi was copied into struct
    When I add 33 to property "test.BDD6502.regsValue"
     And I hex dump memory for 1 bytes from property "test.BDD6502.regsValue"
    Then property "test.BDD6502.lastHexDump" must contain string ": 69 :"
