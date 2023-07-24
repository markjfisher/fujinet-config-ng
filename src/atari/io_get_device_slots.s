; io_get_device_slots.s
;

        .export         io_get_device_slots
        .import         io_copy_dcb, io_deviceslots
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; DeviceSlots[0]* io_get_device_slots(slot_offset)
; slot_offset is:
;   $00: Device slots 0-7
;   $10: Tape slot
.proc io_get_device_slots
        pha     ; save slot_offset

        ldx #IO_FN::get_device_slots
        jsr io_copy_dcb

        pla
        beq do_sio              ; daux1 default is 0. if slot_offset is zero, skip setting it.
        sta IO_DCB::daux1

do_sio:
        jsr SIOV

        setax #io_deviceslots
        rts
.endproc
