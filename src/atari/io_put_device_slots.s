        .export         io_put_device_slots
        .import         io_siov, io_deviceslots
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; void io_put_device_slots()
.proc io_put_device_slots
        setax   #t_io_put_device_slots
        jmp     io_siov
.endproc

.data
.define DS8zL .lobyte(.sizeof(DeviceSlot)*8)
.define DS8zH .hibyte(.sizeof(DeviceSlot)*8)

t_io_put_device_slots:
        .byte $f1, $80, <io_deviceslots, >io_deviceslots, $0f, $00, DS8zL, DS8zH, $00, $00
