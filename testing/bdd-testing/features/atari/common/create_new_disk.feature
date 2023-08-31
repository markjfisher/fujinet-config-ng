Feature: IO library test - fn_io_create_new

  TODO: fix this test
  This tests FN-IO fn_io_create_new

  Scenario Outline: execute _create_new_disk
    Given atari application test setup
      And I add common io files
      And I add atari src file "fn_io_create_new.s"
      And I add file for compiling "features/atari/test-apps/test_fn_io_create_new.s"
      And I add file for compiling "features/atari/stubs/bus-simple.s"
      And I create and load application
      And I write memory at $80 with $ff
      And I write memory at t_host_slot with <host_slot>
      And I write memory at t_device_slot with <device_slot>
      And I write word at t_size with value <size>
      And I write memory at t_path with lo($a000)
      And I write memory at t_path+1 with hi($a000)
      And I write memory at t_newdisk with lo($c000)
      And I write memory at t_newdisk+1 with hi($c000)
      And I write string "<path>" as ascii to memory address $a000
     When I execute the procedure at _init for no more than 1700 instructions
      And I hex dump memory between $1000 and $1010
      And I hex dump memory between $a000 and $a010

    # check the DCB values were set correctly
    Then I expect to see DDEVIC equal $70
     And I expect to see DUNIT equal $01
     And I expect to see DTIMLO equal $fe
     And I expect to see DCOMND equal $e7
     And I expect to see DSTATS equal $80
     And I expect to see DBYTLO equal $06
     And I expect to see DBYTHI equal $01
     And I expect to see DAUX1 equal $00
     And I expect to see DAUX2 equal $00
     And I expect to see DBUFLO equal lo($c000)
     And I expect to see DBUFHI equal hi($c000)

    # check the new disk has expected data
    When I hex dump memory between $c000 and $c000+16
    Then property "test.BDD6502.lastHexDump" must contain string "<new_disk>"

     # check BUS was called
     And I expect to see $80 equal $01

    Examples:
    # note the additonal space in output of hex after 8 chars
    | host_slot | device_slot | size   | path | new_disk                          |
    | 2         | 0           | 90     | /p1  | : d0 02 80 00 02 00 2f 70  31 00  |
    | 3         | 1           | 130    | /p2  | : 10 04 80 00 03 01 2f 70  32 00  |
    | 4         | 1           | 180    | /p3  | : d0 02 00 01 04 01 2f 70  33 00  |
    | 5         | 2           | 360    | /p4  | : a0 05 00 01 05 02 2f 70  34 00  |
    | 6         | 2           | 720    | /p5  | : 40 0b 00 01 06 02 2f 70  35 00  |
    | 7         | 2           | 1440   | /p6  | : 80 16 00 01 07 02 2f 70  36 00  |