Feature: IO library test - fn_io_get_scan_result

  This tests FN-IO fn_io_get_scan_result

  Scenario: execute _fn_io_get_scan_result
    Given fn-io application test setup
      And I add common io files
      And I add libs src file "fn_io/fn_io_get_scan_result.s"
      And I add file for compiling "features/test-setup/test-apps/test_fn_io_get_scan_result.s"
      And I add file for compiling "features/test-setup/stubs/sio-ssid-info.s"
      And I create and load application
      And I write memory at t_network_index with 5
      # tell SIO to write to A000
      And I write memory at t_ssidinfo_loc with $00
      And I write memory at t_ssidinfo_loc+1 with $A0

     When I execute the procedure at _init for no more than 500 instructions

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
     And I expect to see DBUFLO equal lo($A000)
     And I expect to see DBUFHI equal hi($A000)

    # test the ssid was copied into struct
     And I hex dump memory between $A000 and $A008
    Then property "test.BDD6502.lastHexDump" must contain string "ssidtime"

    # test the rssi was copied into struct
     And I hex dump memory between $A021 and $A022
    Then property "test.BDD6502.lastHexDump" must contain string ": 69 :"
