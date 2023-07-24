; io_put_device_slots.s
;

        .export         io_put_device_slots
        .import         io_siov, io_deviceslots
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; void io_put_device_slots()
.proc io_put_device_slots
        ldx #IO_FN::put_device_slots
        jmp io_siov
.endproc
