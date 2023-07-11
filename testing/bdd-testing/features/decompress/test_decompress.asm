; test the decompress library

        .zpvar d_src, d_dst .word = $80

        org $3000
        .link '../../build/tests/decompress.obx'

begin_test
        mwa #z_data d_src
        mwa #output d_dst
        decompress
        rts

z_data  dta $05, $31, $32, $33, $34, $35, $87, $fb, $01, $35, $00

; expected output will be: "this is some text this is some text this is some text this is some text"

output
    :15 dta $00

    run begin_test
