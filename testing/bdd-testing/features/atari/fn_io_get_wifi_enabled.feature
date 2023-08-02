Feature: IO library test - _fn_io_get_wifi_enabled

  This tests Atari _fn_io_get_wifi_enabled

  Scenario Outline: execute _fn_io_get_wifi_enabled
    Given atari simple test setup
      And I add common io files
      And I add atari src file "fn_io_get_wifi_enabled.s"
      And I add file for compiling "features/atari/siov-stubs/siov-dbuflo1.s"
      And I create and load simple application

    When I write memory at t_v with <sio_ret>
     And I execute the procedure at _fn_io_get_wifi_enabled for no more than 70 instructions

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $0f
     And I expect to see DCOMND equal $ea
     And I expect to see DSTATS equal $40
     And I expect to see DBYTLO equal $01
     And I expect to see DBYTHI equal $00
     And I expect to see DAUX1 equal $00
     And I expect to see DAUX2 equal $00

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