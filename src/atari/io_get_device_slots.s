        .export         io_get_device_slots, io_deviceslots
        .import         io_copy_dcb
        .importzp       tmp1
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; *DeviceSlot[0] io_get_device_slots(slot_offset)
;
; returns pointer to entire array of io_deviceslots
; slot_offset is:
;   $00: Device slots 0-7
;   $10: Tape slot
.proc io_get_device_slots
        sta tmp1        ; save slot_offset

        setax   #t_io_get_device_slots
        jsr     io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jsr     SIOV

        setax   #io_deviceslots
        rts
.endproc

.data
.define DS8zL .lobyte(.sizeof(DeviceSlot)*8)
.define DS8zH .hibyte(.sizeof(DeviceSlot)*8)

t_io_get_device_slots:
        .byte $f2, $40, <io_deviceslots, >io_deviceslots, $0f, $00, DS8zL, DS8zH, $00, $00

.bss
io_deviceslots:    .res 8 * .sizeof(DeviceSlot)
