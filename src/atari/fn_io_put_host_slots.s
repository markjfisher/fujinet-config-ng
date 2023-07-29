        .export         _fn_io_put_host_slots
        .import         _fn_io_siov, fn_io_hostslots
        .include        "../inc/macros.inc"
        .include        "fn_io.inc"

; void _fn_io_put_host_slots()
.proc _fn_io_put_host_slots
        setax   #fn_t_io_put_host_slots
        jmp     _fn_io_siov
.endproc

.rodata
.define HS8zL .lobyte(.sizeof(HostSlot)*8)
.define HS8zH .hibyte(.sizeof(HostSlot)*8)

fn_t_io_put_host_slots:
        .byte $f3, $80, <fn_io_hostslots, >fn_io_hostslots, $0f, $00, HS8zL, HS8zH, $00, $00
