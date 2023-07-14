; test the decompress library
        .zpvar d_src, d_dst .word = $80

        org $3000
        .link '../../../build/tests/hex.obx'

begin_test_word
        ; we can use a literal here too, like "hex #$1234 #output"
        hex t_vw #output
        rts

begin_test_byte
        ; we can use a literal here too, like "hex #$1234 #output"
        hexb t_vb #output
        rts

; locations for test to write to
t_vw    .word
t_vb    .byte

output  :4 .byte
