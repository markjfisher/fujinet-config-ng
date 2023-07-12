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
