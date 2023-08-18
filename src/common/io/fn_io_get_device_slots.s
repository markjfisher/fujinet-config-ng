        .export         _fn_io_get_device_slots, t_io_get_device_slots
        .import         _fn_io_siov, fn_io_deviceslots
        .include        "fn_macros.inc"
        .include        "fn_io.inc"

; void _fn_io_get_device_slots()
;
.proc _fn_io_get_device_slots
        setax   #t_io_get_device_slots
        jmp     _fn_io_siov
.endproc

.rodata
.define DS8zL .lobyte(.sizeof(DeviceSlot)*8)
.define DS8zH .hibyte(.sizeof(DeviceSlot)*8)

t_io_get_device_slots:
        .byte $f2, $40, <fn_io_deviceslots, >fn_io_deviceslots, $0f, $00, DS8zL, DS8zH, $00, $00
