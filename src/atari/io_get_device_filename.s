; io_get_device_filename.s
;

        .export         io_get_device_filename
        .import         io_copy_dcb, io_buffer
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; char *io_get_device_filename(device_slot)
.proc io_get_device_filename
        pha     ; save device_slot
        ldx #IO_FN::get_device_filename
        jsr io_copy_dcb

        pla
        sta IO_DCB::daux1
        jsr SIOV

        setax #io_buffer
        rts
.endproc
