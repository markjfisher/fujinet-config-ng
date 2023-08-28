        .export         _fn_io_get_device_slots, t_io_get_device_slots
        .import         _fn_io_copy_dcb, _fn_io_dosiov

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_data.inc"
        .include        "fn_io.inc"

; void fn_io_get_device_slots(void *device_slots)
;
.proc _fn_io_get_device_slots
        axinto  ptr1
        setax   #t_io_get_device_slots
        jsr     _fn_io_copy_dcb

        mwa     ptr1, IO_DCB::dbuflo
        jmp     _fn_io_dosiov
.endproc

.rodata
.define DS8zL .lobyte(.sizeof(DeviceSlot)*8)
.define DS8zH .hibyte(.sizeof(DeviceSlot)*8)

t_io_get_device_slots:
        .byte $f2, $40, $ff, $ff, $0f, $00, DS8zL, DS8zH, $00, $00
