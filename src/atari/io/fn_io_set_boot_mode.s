        .export     _fn_io_set_boot_mode

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_structs.inc"
        .import     _fn_io_copy_dcb

; void _fn_io_set_boot_mode(uint8 mode)
.proc _fn_io_set_boot_mode
        sta     tmp1    ; save mode

        setax   #t_io_set_boot_mode
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jmp     SIOV
.endproc

.rodata
t_io_set_boot_mode:
        .byte $d9, $00, $00, $00, $0f, $00, $00, $00, $ff, $00