Feature:  Machine state test

  This tests expected machine state

  Scenario: Simple machine state test
    Given I have a simple 6502 system
    And I create directory "build/tests"
    And I create file "build/tests/test.a" with
  """
  ; begin
    org $400
  start
    lda #0
    php
    lda #12
    ldx #14
    ldy #17
    plp
    rts

    run start
  """
    And I run the command line: mads -s -o:build/tests/test.xex -t:build/tests/test.lbl build/tests/test.a
    And I load xex "build/tests/test.xex"
    And I convert mads-labels file "build/tests/test.lbl" to acme labels file "build/tests/test.al"
    And I load labels "build/tests/test.al"

    When I execute the procedure at start for no more than 100 instructions

    # Note how the label "start" is used below and correctly resolves to be $400 when checking memory
    Then I expect register A equal 12
    And I expect register X equal 14
    And I expect register Y equal 17
    # stC = 1
    # stZ = 2
    # stI = 4
    # stD = 8
    # stV = 64
    # stN = 128
    And I expect register ST equal stZ
    # Performs a logical bit set test
    And I expect register ST contain stZ
    And I expect register ST exclude stI