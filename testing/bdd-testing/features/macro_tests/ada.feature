Feature: MACRO tests - ada

  This tests ada macro.

  Scenario Outline: ada adds the A register to a memory value, dealing with high byte
    Given atari simple test setup
      And I add file for compiling "features/macro_tests/test_ada.s"
      And I create and load simple application

     When I write word at t_t1 with hex <input>
     When I set register A to <A>
     When I execute the procedure at test_ada for no more than 10 instructions
     
     Then I expect to see t_t1 equal lo(<result>)
      And I expect to see t_t1+1 equal hi(<result>)

  Examples:
  | input | A   | result | comment                    |
  | 0000  | $ff | $00ff  | no increment of high byte  |
  | 0001  | $ff | $0100  | increment of high byte     |
  | abcd  | $32 | $abff  | no inc                     |
  | abcd  | $ff | $accc  | inc                        |
