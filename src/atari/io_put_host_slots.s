        .export         io_put_host_slots
        .import         io_siov, pushax, io_hostslots
        .include        "../inc/macros.inc"
        .include        "io.inc"

; void io_put_host_slots()
.proc io_put_host_slots
        pushax #t_io_put_host_slots
        jmp io_siov
.endproc

.data
.define HS8zL .lobyte(.sizeof(HostSlot)*8)
.define HS8zH .hibyte(.sizeof(HostSlot)*8)

t_io_put_host_slots:
        .byte $f3, $80, <io_hostslots, >io_hostslots, $0f, $00, HS8zL, HS8zH, $00, $00
