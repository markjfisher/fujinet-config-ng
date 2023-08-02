Feature: IO library test - _fn_io_get_scan_result

  This tests Atari _fn_io_get_scan_result

  Scenario: execute _fn_io_get_scan_result
    Given atari simple test setup
      And I add common io files
      And I add atari src file "io/fn_io_get_scan_result.s"
      And I add file for compiling "features/atari/io/siov-stubs/siov-ssid-info.s"
      And I create and load simple application
      And I write memory at $80 with $00

     When I set register A to 5
      And I execute the procedure at _fn_io_get_scan_result for no more than 250 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $fc
     And I expect to see DSTATS equal $40
     And I expect to see DBYTLO equal 34
     And I expect to see DBYTHI equal $00
     And I expect to see DAUX1 equal $05
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo(fn_io_ssidinfo)
     And I expect to see DBUFHI equal hi(fn_io_ssidinfo)

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
