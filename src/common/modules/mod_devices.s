        .export     mod_devices, devices_fetched, device_selected
        .import     _fn_io_get_device_slots, _fn_highlight_line, kb_global, current_line
        .import     pusha, pushax, show_list
        .import     _fn_clrscr, _fn_put_help
        .import     _malloc, _free
        .import     debug

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

.proc mod_devices
        jsr     _fn_clrscr

        ; now we're using malloc, we don't have perm. storage for device slots, so need to always call SIO here.
        ; Maybe this needs to be more permanent?

        jsr     debug
        lda     #<(.sizeof(DeviceSlot)*8)
        ldx     #>(.sizeof(DeviceSlot)*8)
        jsr     _malloc
        axinto  md_device_slots         ; save memory location

        ; ax set already to location
        jsr     _fn_io_get_device_slots
        mva     #$01, devices_fetched

        jsr     display_devices

        ; FREE
        setax   md_device_slots
        jsr     _free

        ; highlight current device
        mva     device_selected, current_line
        jsr     _fn_highlight_line

        ; handle keyboard
        pusha   #7              ; only 8 entries on screen
        pusha   #Mod::hosts     ; previous
        pusha   #Mod::done      ; next
        pushax  #device_selected   ; our current host
        setax   #mod_devices_kb
        jmp     kb_global          ; rts from this will drop out of module

display_devices:
        pusha   #.sizeof(DeviceSlot)
        mwa     md_device_slots, ptr1
        adw     ptr1, #$02
        setax   ptr1            ; string is 2 chars in the struct
        jmp     show_list

; the local module's keyboard handling routines
; TODO: implement Eject etc.
mod_devices_kb:
        ldx     #KBH::NOT_HANDLED
        rts

.endproc

.bss
host_index:             .res 1
md_device_slots:        .res 2

.data
devices_fetched:        .byte 0
device_selected:        .byte 0
