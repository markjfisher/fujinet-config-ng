Feature: IO library test - _fn_io_get_adapter_config

  This tests Atari _fn_io_get_adapter_config

  Scenario: execute _fn_io_get_adapter_config
    Given atari simple test setup
      And I add file for compiling "../../src/atari/fn_io_get_adapter_config.s"
      And I add file for compiling "../../src/atari/fn_io_siov.s"
      And I add file for compiling "../../src/atari/fn_io_copy_dcb.s"
      And I add file for compiling "features/atari/siov-stubs/siov-adapter-config.s"
      And I create and load simple application

     When I execute the procedure at _fn_io_get_adapter_config for no more than 1005 instructions
      And I print ascii from fn_io_adapter_config to fn_io_adapter_config+144

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $e8
     And I expect to see DSTATS equal $40
     And I expect to see DBYTLO equal 140
     And I expect to see DBYTHI equal $00
     And I expect to see DAUX1 equal $00
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo(fn_io_adapter_config)
     And I expect to see DBUFHI equal hi(fn_io_adapter_config)

    # Test the return values at A/X point to a struct with correct data
    Then string at registers AX contains
    """
      33:ssid name!!
      64:the 'hostname'
       4:ip
       4:gw
       4:nm
       4:dns
       6:macadd
       6:bssid
      15:version string
    """