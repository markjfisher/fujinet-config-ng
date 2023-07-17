; test the stdlib library
        .zpvar t1, t2 .word = $f0

        org $1000
        .link '../../../build/tests/stdlib.obx'

begin_test_strcpy
        strcpy #src #dst
        rts

begin_test_strappend
        strappend #src #dst
        rts

src :64 .byte
dst :64 .byte
