; test io routines
        icl "../../../../src/libs/atari/inc/os.inc"
        icl "../../../../src/libs/atari/inc/antic.inc"

        org $1000
        .link '../../build/tests/io.obx'
