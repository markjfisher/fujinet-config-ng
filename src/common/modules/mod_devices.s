        .export     mod_devices, devices_fetched, device_selected
        .import     _fn_io_get_device_slots, fn_io_deviceslots, _dev_highlight_line, mod_kb, current_line
        .import     pusha, pushax, show_list
        .import     _fn_clrscr, _fn_put_help
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

.proc mod_devices
        jsr     _fn_clrscr

        ; do we have devices data read?
        lda     devices_fetched
        bne     :+

        jsr     _fn_io_get_device_slots
        mva     #$01, devices_fetched

:
        jsr     display_devices

        ; highlight current device
        mva     device_selected, current_line
        jsr     _dev_highlight_line

        ; handle keyboard
        pusha   #7              ; only 8 entries on screen
        pusha   #Mod::hosts     ; previous
        pusha   #Mod::done      ; next
        pushax  #device_selected   ; our current host
        setax   #mod_devices_kb
        jmp     mod_kb          ; rts from this will drop out of module


display_devices:
        pusha   #.sizeof(DeviceSlot)
        setax   #fn_io_deviceslots+2    ; string is 2 chars in the struct
        jmp     show_list

; the local module's keyboard handling routines
mod_devices_kb:
        ldx     #KB_HANDLER::NOT_HANDLED
        rts

.endproc

.bss
host_index:     .res 1

.data
devices_fetched:   .byte 0
device_selected:  .byte 0