; test io routines
        icl "../../../../src/libs/atari/inc/os.inc"
        icl "../../../../src/libs/atari/inc/antic.inc"

        ; some zero page vars for our routines to use
        .zpvar t1, t2 .word = $f0

        opt r+
        org $1000
        .link '../../build/tests/stdlib.obx'
        .link '../../build/tests/io.obx'

