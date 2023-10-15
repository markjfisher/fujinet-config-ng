Feature: sbc tests

  Test direct subtraction and inversion vs temporary storage

  Scenario Outline: sbc via temporary storage in ZP gives correct result for r = b-a
    Given atari simple test setup
      And I add file for compiling "features/general/sbc_tests.s"
      And I create and load simple atari application

     And I write memory at t_b with <b>
     And I set register A to <a>
    When I execute the procedure at sbs_test_1_zp for no more than 5 instructions
    Then I expect register A equal <r>

  Examples:
      | b   | a   | r   | comment           |
      | $0a | $02 | $08 | simple 10-8 = 2   |
      | $0a | $0a | $00 | simple 10-10 = 0  |
      | $e0 | $d4 | $0c | 224-212 = 12      |
      | $05 | $33 | $d2 | under! 5-51 = -46 |

  Scenario Outline: sbc via temporary storage in MEM gives correct result for r = b-a
    Given atari simple test setup
      And I add file for compiling "features/general/sbc_tests.s"
      And I create and load simple atari application

     And I write memory at t_b with <b>
     And I set register A to <a>
    When I execute the procedure at sbs_test_1_mem for no more than 5 instructions
    Then I expect register A equal <r>

  Examples:
      | b   | a   | r   | comment           |
      | $0a | $02 | $08 | simple 10-8 = 2   |
      | $0a | $0a | $00 | simple 10-10 = 0  |
      | $e0 | $d4 | $0c | 224-212 = 12      |
      | $05 | $33 | $d2 | under! 5-51 = -46 |

  Scenario Outline: sbc via eor/adc gives correct result for r = b-a
    Given atari simple test setup
      And I add file for compiling "features/general/sbc_tests.s"
      And I create and load simple atari application

     And I write memory at t_b with <b>
     And I set register A to <a>
    When I execute the procedure at sbs_test_2 for no more than 6 instructions
    Then I expect register A equal <r>

  Examples:
      | b   | a   | r   | comment           |
      | $0a | $02 | $08 | simple 10-8 = 2   |
      | $0a | $0a | $00 | simple 10-10 = 0  |
      | $e0 | $d4 | $0c | 224-212 = 12      |
      | $05 | $33 | $d2 | under! 5-51 = -46 |
