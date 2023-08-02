; test the decompress library

        .import         decompress, pushax
        .export         _main, output
        .include        "../../../../../src/inc/fn_macros.inc"

.proc _main
        pushax #z_data
        setax  #output
        jsr decompress
        rts
.endproc

.data
; decompresses to "123451234512345"
z_data:  .byte $05, $31, $32, $33, $34, $35, $87, $fb, $01, $35, $00
output:  .res 16
