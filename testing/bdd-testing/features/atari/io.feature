Feature: IO library test

  This tests Atari io.asm library

  Scenario Outline: execute io_error should set A
    Given basic setup test "io_error"
    And I mads-compile "io" from "../../src/libs/atari/io.asm"
    And I build and load the application "test_io" from "features/atari/test_io.asm"

  Examples:
    | init | A     |
    | 0    | 0     |
    # | 1    | 0     |
    # | 127  | 0     |
    # | 128  | 128   |
    # | 129  | 128   |
    # | 255  | 128   |
