Feature: Module mod_init test

  This tests _mod_init module.

  TODO: rework this module test

  Scenario: Running mod_init initialises module
    Given atari application test setup
    #   And I add atari src file "screen/clr_scr.s"
    #   And I add common/modules src file "kb_global.s"
    #   And I add common/modules src file "mod_boot.s"
    #   And I add common/modules src file "mod_init.s"
    #   And I add file for compiling "features/common/modules/test_mod_init.s"
    #   And I create and load application
    #   And I write memory at t_wifi_enabled with <wifi_enabled>
    #   And I write memory at t_wifi_status with <wifi_status>
    #   And I write memory at t_ssid_fetched with <ssid_fetched>
    #   And I execute the procedure at _init for no more than 50 instructions
    #  # test that the mod was set according to the state of wifi and ssid
    #  Then I expect to see mod_current equal <mod>

    # # stub application fakes _dev_init, and sets value 1 at $80
    # Then I expect to see $80 equal $01

    # Examples:
    # | wifi_enabled | wifi_status | ssid_fetched | mod | comment                      |
    # | 0            | 0           | 0            | 1   | wifi not enabled -> hosts    |
    # | 1            | 3           | 0            | 1   | enabled + connected -> hosts |
    # | 1            | 4           | 0            | 3   | enabled + not-connected + no ssid info -> wifi (set wifi) |
    # | 1            | 4           | 1            | 3   | enabled + not connected + has ssidinfo -> wifi (connect)  |
