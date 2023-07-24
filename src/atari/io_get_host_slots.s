; io_get_host_slots.s
;

        .export         io_get_host_slots
        .import         io_siov
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; void io_get_host_slots()
.proc io_get_host_slots
        ldx #IO_FN::get_host_slots
        jmp io_siov
.endproc
