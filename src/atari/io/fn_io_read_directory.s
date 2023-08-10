        .export     _fn_io_read_directory

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_structs.inc"
        .import     _fn_io_copy_dcb, fn_io_buffer, popa

; char *fn_io_read_directory(unsigned char maxlen, unsigned char aux2)
;
; See https://github.com/FujiNetWIFI/fujinet-platformio/wiki/SIO-Command-%24F6-Read-Directory for aux2 value
.proc _fn_io_read_directory
        sta     tmp1    ; aux2 param
        popa    tmp2    ; maxlen

        ; clear buffer for maxlen bytes (still in A)
        beq     no_zero

clear_buffer:
        tay
        mwa     #fn_io_buffer, ptr1
        lda     #$00
:       dey
        sta     (ptr1), y
        cpy     #$00
        bne     :-

no_zero:
        setax   #t_io_read_directory
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux2
        mva     tmp2, IO_DCB::dbytlo
        mva     tmp2, IO_DCB::daux1
        mva     #$7f, fn_io_buffer

        jsr     SIOV
        setax   #fn_io_buffer
        rts

.endproc

.rodata
t_io_read_directory:
        .byte $f6, $40, <fn_io_buffer, >fn_io_buffer, $0f, $00, $ff, $00, $ff, $ff
