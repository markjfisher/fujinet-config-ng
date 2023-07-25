; io_put_device_slots.s
;

        .export         io_set_device_filename
        .import         io_copy_dcb
        .importzp       tmp1
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; void io_set_device_filename(device_slot)
.proc io_set_device_filename
        sta tmp1     ; save device_slot
        ldx #IO_FN::set_device_filename
        jsr io_copy_dcb

        mva tmp1, IO_DCB::daux1
        jmp SIOV
.endproc
