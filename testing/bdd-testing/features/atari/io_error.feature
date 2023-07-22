Feature: IO library test - io_error

  This tests Atari io_error

  ##############################################################################################################
  Scenario Outline: execute io_error should set A
    Given basic atari setup test
      And I add file for compiling "../../src/atari/io_error.s"
      And I create and load application

     When I write memory at DSTATS with <init>
      And I execute the procedure at io_error for no more than 10 instructions
     Then I expect register A equal <A>

    # A should contain (init & 0x80) as simplest test if bit 7 is set.
    Examples:
      | init |  A   |
      | 0x00 | 0x00 |
      | 0x01 | 0x00 |
      | 0x7f | 0x00 |
      | 0x80 | 0x80 |
      | 0x81 | 0x80 |
      | 0xff | 0x80 |