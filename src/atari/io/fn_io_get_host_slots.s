        .export         _fn_io_get_host_slots, fn_io_hostslots
        .import         _fn_io_siov
        .include        "fn_macros.inc"
        .include        "fn_io.inc"

; void _fn_io_get_host_slots()
.proc _fn_io_get_host_slots
        setax   #t_io_get_host_slots
        jmp     _fn_io_siov
.endproc

.rodata
.define HS8zL .lobyte(.sizeof(HostSlot)*8)
.define HS8zH .hibyte(.sizeof(HostSlot)*8)

t_io_get_host_slots:
        .byte $f4, $40, <fn_io_hostslots, >fn_io_hostslots, $0f, $00, HS8zL, HS8zH, $00, $00

.bss
fn_io_hostslots:      .res 8 * .sizeof(HostSlot)
