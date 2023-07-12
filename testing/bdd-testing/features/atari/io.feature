Feature: IO library test

  This tests Atari io.asm library

  Scenario Outline: execute io_error should set A
    Given basic setup test "io_error"
    And I mads-compile "io" from "../../src/libs/atari/io.asm"
    And I build and load the application "test_io" from "features/atari/test_io.asm"

    When I write memory at dstats with <init>
    When I execute the procedure at test_io_error for no more than 50 instructions

    Then I expect register A equal <A>

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

    When I execute the procedure at test_io_init for no more than 50 instructions

    Then I expect to see noclik equal $ff
     And I expect to see shflok equal $00
     And I expect to see coldst equal $01
     And I expect to see sdmctl equal $00
