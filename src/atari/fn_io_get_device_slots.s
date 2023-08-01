        .export         _fn_io_get_device_slots
        .import         _fn_io_copy_dcb, fn_io_deviceslots
        .include        "atari.inc"
        .include    "zeropage.inc"
        .include        "../inc/macros.inc"
        .include        "fn_io.inc"

; *DeviceSlot[0] _fn_io_get_device_slots(slot_offset)
;
; returns pointer to entire array of fn_io_deviceslots
; slot_offset is:
;   $00: Device slots 0-7
;   $10: Tape slot
.proc _fn_io_get_device_slots
        sta tmp1        ; save slot_offset

        setax   #fn_t_io_get_device_slots
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jsr     SIOV

        setax   #fn_io_deviceslots
        rts
.endproc

.rodata
.define DS8zL .lobyte(.sizeof(DeviceSlot)*8)
.define DS8zH .hibyte(.sizeof(DeviceSlot)*8)

fn_t_io_get_device_slots:
        .byte $f2, $40, <fn_io_deviceslots, >fn_io_deviceslots, $0f, $00, DS8zL, DS8zH, $00, $00
