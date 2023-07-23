Feature:  Decompress library test

  This tests decompress library.

  Scenario: Decompressing Compressed Text
    Given atari application test setup
      And I add file for compiling "../../src/util/decompress.s"
      And I add file for compiling "features/util/decompress/test_decompress.s"
      And I create and load application

     When I execute the procedure at _init for no more than 210 instructions

     # returns with A = 0
     Then I expect register A equal 0

     When I hex dump memory between output and output+15
     Then property "test.BDD6502.lastHexDump" must contain string "123451234512345"
