; test the decompress library
        .zpvar t1, t2 .word = $f0
        org $1000
        .link '../../../build/tests/decompress.obx'

begin_test
        decompress #z_data #output
        rts

; decompresses to "123451234512345"
z_data  dta $05, $31, $32, $33, $34, $35, $87, $fb, $01, $35, $00
output  :15 .byte
