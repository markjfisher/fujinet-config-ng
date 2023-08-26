        .export     mod_devices, devices_fetchedX, device_selectedX
        .import     _fn_io_get_device_slots, fn_io_deviceslots, _fn_highlight_line, kb_global, current_line
        .import     pusha, pushax, show_list
        .import     _fn_clrscr, _fn_put_help, _fn_put_status
        .import     _fn_io_set_device_filename
        .import     fn_io_buffer
        .import     host_selected
        .import     sl_list_num
        .import     mod_devices_show_list_num
        .import     md_h1, md_s1, md_s3
        .import     device_selected, devices_fetched

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"

.proc mod_devices
        jsr     _fn_clrscr
        put_status #0, #md_s1
        put_status #1, #md_s3
        put_help #1, #md_h1

        ; do we have devices data read?
        lda     devices_fetched
        bne     :+

        jsr     _fn_io_get_device_slots
        mva     #$01, devices_fetched

:
        jsr     display_devices

        ; highlight current device
        mva     device_selected, current_line
        jsr     _fn_highlight_line

        ; handle keyboard
        pusha   #7              ; only 8 entries on screen
        pusha   #Mod::hosts     ; previous
        pusha   #Mod::done      ; next
        pushax  #device_selected   ; our current device
        setax   #mod_devices_kb
        jmp     kb_global          ; rts from this will drop out of module


display_devices:
        pushax  #mod_devices_show_list_num
        pusha   #.sizeof(DeviceSlot)
        setax   #fn_io_deviceslots+2    ; string is 2 chars in the struct
        jmp     show_list

; the local module's keyboard handling routines
mod_devices_kb:
        cmp     #'E'
        bne     not_eject

        ; eject highlighted entry, which involves setting device slot to empty string and put/get device slots
        ; new version is just save device file name with no value
        lda     #$00
        sta     fn_io_buffer
        pusha   #$00
        pusha   host_selected
        lda     device_selected
        jsr     _fn_io_set_device_filename
        
        ; read the device slots back so screen repopulates
        jsr     _fn_io_get_device_slots

        ldx     #KBH::EXIT
        rts

not_eject:
        ldx     #KBH::NOT_HANDLED
        rts

.endproc

.data
devices_fetchedX:        .byte 0
device_selectedX:        .byte 0
