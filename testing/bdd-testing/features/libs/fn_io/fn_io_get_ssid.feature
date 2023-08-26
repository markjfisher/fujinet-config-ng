Feature: IO library test - fn_io_get_ssid

  This tests FN-IO fn_io_get_ssid

  Scenario: execute _fn_io_get_ssid
    Given fn-io application test setup
      And I add common io files
      And I add libs src file "fn_io/fn_io_get_ssid.s"
      And I add file for compiling "features/test-setup/test-apps/test_fn_io_get_ssid.s"
      And I add file for compiling "features/test-setup/stubs/sio-netconfig.s"
      And I create and load application
      And I write memory at t_netconfig_loc with $00
      And I write memory at t_netconfig_loc+1 with $A0
      # And I print memory from SIOV to SIOV+192

     When I execute the procedure at _init for no more than 550 instructions
      And I print memory from $A000 to $A000+98

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
     And I expect to see DBUFLO equal lo($A000)
     And I expect to see DBUFHI equal hi($A000)

    # test the ssid was copied into struct
     And I hex dump memory between $A000 and $A008
    Then property "test.BDD6502.lastHexDump" must contain string "yourssid"

    # test the password was copied into struct
     And I hex dump memory between $A021 and $A029
    Then property "test.BDD6502.lastHexDump" must contain string "password"
