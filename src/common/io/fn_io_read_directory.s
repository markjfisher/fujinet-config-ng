        .export     _fn_io_read_directory
        .import     _fn_io_copy_dcb, fn_io_buffer, popa, _fn_memclr_page, _fn_io_dosiov

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; char *fn_io_read_directory(unsigned char maxlen, unsigned char aux2)
;
; See https://github.com/FujiNetWIFI/fujinet-platformio/wiki/SIO-Command-%24F6-Read-Directory for aux2 value
.proc _fn_io_read_directory
        sta     tmp1    ; aux2 param
        popa    tmp2    ; maxlen

        setax   #fn_io_buffer           ; clear io_buffer, which is 256 bytes long
        jsr     _fn_memclr_page

        setax   #t_io_read_directory
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux2
        mva     tmp2, IO_DCB::dbytlo
        mva     tmp2, IO_DCB::daux1
        mva     #$7f, fn_io_buffer

        jsr     _fn_io_dosiov
        setax   #fn_io_buffer
        rts

.endproc

.rodata
t_io_read_directory:
        .byte $f6, $40, <fn_io_buffer, >fn_io_buffer, $0f, $00, $ff, $00, $ff, $ff