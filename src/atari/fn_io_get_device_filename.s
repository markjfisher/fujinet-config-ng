        .export         _fn_io_get_device_filename
        .import         _fn_io_copy_dcb, fn_io_buffer
        .importzp       tmp1
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "fn_io.inc"

; char* _fn_io_get_device_filename(device_slot)
.proc _fn_io_get_device_filename
        sta     tmp1        ; save device_slot
        setax   #fn_t_io_get_device_filename
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jsr     SIOV

        setax   #fn_io_buffer
        rts
.endproc

.rodata

fn_t_io_get_device_filename:
        .byte $da, $40, <fn_io_buffer, >fn_io_buffer, $0f, $00, $00,   $01,   $ff, $00

