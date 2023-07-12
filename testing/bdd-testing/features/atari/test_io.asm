; test io routines
        icl "../../../../src/libs/atari/inc/os.inc"
        icl "../../../../src/libs/atari/inc/antic.inc"

        org $1000
        .link '../../build/tests/io.obx'

nothing jmp nothing

test_io_error
        io_error
        rts

test_io_init
        io_init
        rts

        run nothing