; test io
        icl "../../../../src/libs/atari/inc/os.inc"

        org $1000
        .link '../../build/tests/io.obx'

nothing jmp nothing

test_io_error
        mva init_io DSTATS
        io_error
        rts

init_io dta $00

        run nothing