        .export     _fn_io_read_directory
        .import     fn_io_copy_dcb, popa, _fn_io_dosiov

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; char *fn_io_read_directory(unsigned char maxlen, unsigned char aux2, void *buffer)
;
; See https://github.com/FujiNetWIFI/fujinet-platformio/wiki/SIO-Command-%24F6-Read-Directory for aux2 value
.proc _fn_io_read_directory
        axinto  ptr1    ; buffer location
        popa    tmp1    ; aux2 param
        popa    tmp2    ; maxlen

        setax   #t_io_read_directory
        jsr     fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux2
        mva     tmp2, IO_DCB::dbytlo
        mva     tmp2, IO_DCB::daux1
        mwa     ptr1, IO_DCB::dbuflo

        ldy     #$00
        mva     #$7f, {(ptr1), y}       ; it's the thing to do apparantly. I think this is a DIR marker

        jsr     _fn_io_dosiov
        setax   ptr1
        rts

.endproc

.rodata
t_io_read_directory:
        .byte $f6, $40, $ff, $ff, $0f, $00, $ff, $00, $ff, $ff
