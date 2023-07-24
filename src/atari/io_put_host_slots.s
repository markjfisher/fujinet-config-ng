; io_put_host_slots.s
;

        .export         io_put_host_slots
        .import         io_siov
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; void io_put_host_slots()
.proc io_put_host_slots
        ldx #IO_FN::put_host_slots
        jmp io_siov
.endproc
