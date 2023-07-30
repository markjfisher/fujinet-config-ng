Feature: IO library test - _fn_io_get_ssid

  This tests Atari _fn_io_get_ssid

  Scenario: execute _fn_io_get_ssid
    Given atari simple test setup
      And I add file for compiling "../../src/atari/fn_io_mem_io_net_config.s"
      And I add file for compiling "../../src/atari/fn_io_get_ssid.s"
      And I add file for compiling "../../src/atari/fn_io_siov.s"
      And I add file for compiling "../../src/atari/fn_io_copy_dcb.s"
      And I add file for compiling "features/atari/siov-stubs/siov-netconfig.s"
      And I create and load simple application
      And I print memory from SIOV to SIOV+192

     When I execute the procedure at _fn_io_get_ssid for no more than 530 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $fe
     And I expect to see DSTATS equal $40
     And I expect to see DBYTLO equal 97
     And I expect to see DBYTHI equal $00
     And I expect to see DAUX1 equal $00
     And I expect to see DAUX2 equal $00

    # A/X contains L/H address of NetConfig created. Returned in property test.BDD6502.regsValue
    When I convert registers AX to address

    # test the ssid was copied into struct
     And I hex dump memory for 8 bytes from property "test.BDD6502.regsValue"
    Then property "test.BDD6502.lastHexDump" must contain string "yourssid"

    # test the password was copied into struct
    When I add 33 to property "test.BDD6502.regsValue"
     And I hex dump memory for 8 bytes from property "test.BDD6502.regsValue"
    Then property "test.BDD6502.lastHexDump" must contain string "password"
