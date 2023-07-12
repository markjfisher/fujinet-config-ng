; test io
        icl "../../../../src/libs/atari/inc/os.inc"

        org $1000
        .link '../../build/tests/io.obx'

nothing jmp nothing

test_io_error
        io_error
        rts

        run nothing