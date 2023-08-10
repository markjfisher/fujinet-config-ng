        .export         _fn_io_set_device_filename
        .import         _fn_io_copy_dcb, fn_io_buffer
        .include        "zeropage.inc"
        .include        "atari.inc"
        .include        "fn_macros.inc"
        .include        "fn_structs.inc"

; void _fn_io_set_device_filename(device_slot)
.proc _fn_io_set_device_filename
        sta     tmp1     ; save device_slot

        setax   #t_io_set_device_filename
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jmp     SIOV
.endproc

.rodata
t_io_set_device_filename:
        .byte $e2, $80, <fn_io_buffer, >fn_io_buffer, $0f, $00, $00, $01, $ff, $00
