        .export     _fn_io_read_directory_block

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .import     _fn_io_copy_dcb, fn_io_buffer, popa, _fn_memclr_page

; char *fn_io_read_directory_block(uint8 maxlen, uint8 pages)
;
; pages is number of 256 blocks to request
.proc _fn_io_read_directory_block
        sta     tmp1    ; pages
        popa    tmp2    ; maxlen
        ora     #$C0    ; force bits 7&8 to mark this as block mode
        sta     tmp2

        setax   #t_io_read_directory_block
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        sta     IO_DCB::dbythi
        mva     tmp2, IO_DCB::daux2
        mva     #$7f, fn_io_buffer

        jsr     SIOV
        setax   #fn_io_buffer
        rts

.endproc

.rodata
; force into $4000
t_io_read_directory_block:
        .byte $f6, $40, <$4000, >$4000, $05, $00, $00, $ff, $ff, $ff
