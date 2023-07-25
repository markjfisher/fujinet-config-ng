        .export         io_get_host_slots, io_hostslots
        .import         io_siov, pushax
        .include        "../inc/macros.inc"
        .include        "io.inc"

; void io_get_host_slots()
.proc io_get_host_slots
        pushax #t_io_get_host_slots
        jmp io_siov
.endproc

.data
.define HS8zL .lobyte(.sizeof(HostSlot)*8)
.define HS8zH .hibyte(.sizeof(HostSlot)*8)

t_io_get_host_slots:
        .byte $f4, $40, <io_hostslots, >io_hostslots, $0f, $00, HS8zL, HS8zH, $00, $00

.bss
io_hostslots:      .res 8 * .sizeof(HostSlot)
