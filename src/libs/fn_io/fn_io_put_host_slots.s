        .export         _fn_io_put_host_slots
        .import         fn_io_copy_dcb, _fn_io_dosiov

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_data.inc"
        .include        "fn_io.inc"

; void _fn_io_put_host_slots()
.proc _fn_io_put_host_slots
        axinto  ptr1
        setax   #t_io_put_host_slots
        jsr     fn_io_copy_dcb

        mwa     ptr1, IO_DCB::dbuflo
        jmp     _fn_io_dosiov
.endproc

.rodata
.define HS8zL .lobyte(.sizeof(HostSlot)*8)
.define HS8zH .hibyte(.sizeof(HostSlot)*8)

t_io_put_host_slots:
        .byte $f3, $80, $ff, $ff, $0f, $00, HS8zL, HS8zH, $00, $00
