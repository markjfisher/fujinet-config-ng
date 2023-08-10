        .export     mod_devices
        .import     mod_current, _fn_clrscr, _dev_highlight_line, fn_io_deviceslots, _fn_io_get_device_slots
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"

.proc mod_devices
        jsr     _fn_clrscr

        ; do we have devices data read?
        lda     devices_fetched
        bne     over

        jsr     _fn_io_get_device_slots
        mva     #$01, devices_fetched

over:
        jsr     display_devices

        ; highlight current host
        jsr     _dev_highlight_line


:       jmp :-
        rts


display_devices:
        ; fn_io_deviceslots is an array of 8 DeviceSlot

.endproc


.data
devices_fetched:   .byte 0
_device_selected:  .byte 0