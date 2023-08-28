        .export     _fn_io_set_directory_position
        .import     fn_io_copy_dcb, _fn_io_dosiov

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"

; void fn_io_set_directory_position(uint16_t pos)
.proc _fn_io_set_directory_position
        axinto  tmp1        ; save the directory pos to tmp1/2

        setax   #t_io_set_directory_position
        jsr     fn_io_copy_dcb

        mwa     tmp1, IO_DCB::daux1
        jmp     _fn_io_dosiov
.endproc

.rodata
t_io_set_directory_position:
        .byte $e4, $00, $00, $00, $0f, $00, $00, $00, $ff, $ff