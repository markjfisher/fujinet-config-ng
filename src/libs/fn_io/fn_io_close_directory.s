        .export     _fn_io_close_directory

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .import     fn_io_copy_dcb, _fn_io_dosiov

; void fn_io_close_directory(uint8_t host_slot)
.proc _fn_io_close_directory
        sta     tmp1    ; save host_slot

        setax   #t_io_close_directory
        jsr     fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jmp     _fn_io_dosiov
.endproc

.rodata
t_io_close_directory:
        .byte $f5, $00, $00, $00, $0f, $00, $00, $00, $ff, $00
