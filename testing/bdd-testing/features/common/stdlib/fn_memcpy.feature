Feature: Stdlib library tests - fn_memcpy

  This tests fn_memcpy in stdlib library.

  Scenario: Moving memory with _fn_memcpy
    Given atari simple test setup
      And I add common/stdlib src file "fn_memcpy.s"
      And I add file for compiling "features/common/stdlib/test_fn_memcpy.s"
      And I create and load simple application

     # fill both src and dst with data
     And I fill memory from t_src to t_src+31 with $ff
     And I start writing memory at t_src
     And I write the following hex bytes
         | 01 02 03 04 05 06 07 08 |

     And I write memory at t_max with 4
    When I execute the procedure at test_fn_memcpy for no more than 85 instructions
     And I start comparing memory at t_dst
    Then I assert the following hex bytes are the same
         | 01 02 03 04 ff |

  Scenario: Moving memory with _fn_memcpy_fast
    Given atari simple test setup
      And I add common/stdlib src file "fn_memcpy.s"
      And I add file for compiling "features/common/stdlib/test_fn_memcpy.s"
      And I create and load simple application

     # fill both src and dst with data
     And I fill memory from t_src to t_src+31 with $ff
     And I start writing memory at t_src
     And I write the following hex bytes
         | 01 02 03 04 05 06 07 08 |

     And I write memory at t_max with 4
    When I execute the procedure at test_fn_memcpy_fast for no more than 35 instructions
     And I print memory from t_src to t_src+20
     And I start comparing memory at t_dst
    Then I assert the following hex bytes are the same
         | 01 02 03 04 ff |
