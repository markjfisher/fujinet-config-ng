Feature: Screen Functions test - _fn_put_c

  This tests Atari screen function _fn_put_c to place a character within the display area

  Scenario Outline: Running _fn_put_c writes internal code to given screen coordinates
    Given atari application test setup
      And I add atari/screen src file "fn_put_c.s"
      And I add file for compiling "features/atari/screen/test_fn_put_c.s"
      And I create and load application
      And I write memory at t_x with <x>
      And I write memory at t_y with <y>
      And I write memory at t_c with <char>
      And I execute the procedure at _init for no more than 35 instructions

     # Validate _fn_get_scrloc was called with correct parameters
     Then I expect to see t_save_x equal <x>
      And I expect to see t_save_y equal <y>

      # Validate screen code written to our location
      And I expect to see t_loc equal <internal>

  Examples:
  | x  | y  | c  | char | internal |
  | 1  | 2  | A  | $41  | $21      |
  | 3  | 4  | a  | $61  | $61      |
  | 5  | 6  | 0  | $30  | $10      |
  | 7  | 8  | !  | $21  | $01      |