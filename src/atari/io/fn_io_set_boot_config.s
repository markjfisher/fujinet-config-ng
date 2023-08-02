        .export     _fn_io_set_boot_config

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "../inc/dcb.inc"
        .import     _fn_io_copy_dcb

; void fn_io_set_boot_config(uint8 toggle)
.proc _fn_io_set_boot_config
        sta     tmp1

        setax   #t_io_set_boot_config
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jmp     SIOV
.endproc

.rodata
t_io_set_boot_config:
        .byte $d9, $00, $00, $00, $0f, $00, $00, $00, $ff, $00