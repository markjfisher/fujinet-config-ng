Feature:  Decompress library test

  This tests decompress library.

  Scenario: Decompressing Compressed Text
    Given basic setup test "decompress text"

    # compile the library
    And I mads-compile "decompress" from "../../src/libs/util/decompress.asm"

    # compile the test application
    And I build and load the application "test_decompress" from "features/util/decompress/test_decompress.asm"

    When I execute the procedure at begin_test for no more than 1000 instructions

    # returns with A = 0
    Then I expect register A equal 0

    When I hex dump memory between output and output+15
    Then property "test.BDD6502.lastHexDump" must contain string "123451234512345"
