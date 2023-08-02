Feature: IO library test - _fn_io_error

  This tests Atari _fn_io_error

  Scenario Outline: execute _fn_io_error should set A
    Given atari simple test setup
      And I add atari src file "fn_io_error.s"
      And I create and load simple application

     When I write memory at DSTATS with <init>
      And I execute the procedure at _fn_io_error for no more than 10 instructions
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