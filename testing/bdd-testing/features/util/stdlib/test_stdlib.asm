; test the stdlib library
        .zpvar t1, t2 .word = $f0

        org $1000
        .link '../../../build/tests/stdlib.obx'

begin_test_strncpy
        strncpy #dst #src count
        rts

begin_test_strncat
        strncat #dst #src count
        rts

src :64 .byte
dst :64 .byte
count   .byte