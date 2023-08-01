Feature: IO library test - _fn_io_get_wifi_status

  This tests Atari _fn_io_get_wifi_status

  Scenario Outline: execute _fn_io_get_wifi_status
    Given atari simple test setup
      And I add common io files
      And I add file for compiling "../../src/atari/fn_io_get_wifi_status.s"
      And I add file for compiling "features/atari/siov-stubs/siov-dbuflo1.s"
      And I create and load simple application

    When I write memory at t_v with <sio_ret>
     And I execute the procedure at _fn_io_get_wifi_status for no more than 65 instructions

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