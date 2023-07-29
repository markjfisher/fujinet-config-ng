; io_put_device_slots.s
;

        .export         io_set_device_filename
        .import         io_copy_dcb, io_buffer
        .importzp       tmp1
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; void io_set_device_filename(device_slot)
.proc io_set_device_filename
        sta     tmp1     ; save device_slot

        setax   #t_io_set_device_filename
        jsr     io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jmp     SIOV
.endproc

.rodata
t_io_set_device_filename:
        .byte $e2, $80, <io_buffer, >io_buffer, $0f, $00, $00, $01, $ff, $00
