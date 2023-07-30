        .export     _fn_io_close_directory

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "../inc/macros.inc"
        .include    "fn_io.inc"
        .import     _fn_io_copy_dcb

; void io_close_directory(uint8 host_slot)
.proc _fn_io_close_directory
        sta     tmp1    ; save host_slot

        setax   #t_io_close_directory
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jmp     SIOV
.endproc

.rodata
t_io_close_directory:
        .byte $f5, $00, $00, $00, $0f, $00, $00, $00, $ff, $00
