; test the decompress library

        .importzp       ptr1, ptr2
        .import         decompress
        .export         begin_test, output
        .include        "../../../../../src/inc/macros.inc"

.proc begin_test
        mwa #z_data, ptr1
        mwa #output, ptr2
        jsr decompress
        rts
.endproc

.data
; decompresses to "123451234512345"
z_data:  .byte $05, $31, $32, $33, $34, $35, $87, $fb, $01, $35, $00
output:  .res 15
