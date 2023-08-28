        .export     _fn_io_set_boot_config
        .import     fn_io_copy_dcb, _fn_io_dosiov

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; void fn_io_set_boot_config(uint8_t toggle)
.proc _fn_io_set_boot_config
        sta     tmp1

        setax   #t_io_set_boot_config
        jsr     fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jmp     _fn_io_dosiov
.endproc

.rodata
t_io_set_boot_config:
        .byte $d9, $00, $00, $00, $0f, $00, $00, $00, $ff, $00