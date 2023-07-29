        .export         io_get_device_filename
        .import         io_copy_dcb, io_buffer
        .importzp       tmp1
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; char* io_get_device_filename(device_slot)
.proc io_get_device_filename
        sta     tmp1        ; save device_slot
        setax   #t_io_get_device_filename
        jsr     io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jsr     SIOV

        setax   #io_buffer
        rts
.endproc

.rodata

t_io_get_device_filename:
        .byte $da, $40, <io_buffer, >io_buffer, $0f, $00, $00,   $01,   $ff, $00

