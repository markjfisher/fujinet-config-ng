        .export     mod_hosts, hosts_fetched, host_selected, device_selected, devices_fetched
        .import     _fn_io_get_host_slots, fn_io_hostslots, _fn_highlight_line, kb_global, current_line
        .import     pusha, pushax, show_list, _fn_edit_hosts_entry, mod_current
        .import     _fn_clrscr, _fn_put_help, _fn_put_status
        .import     _fn_io_get_device_slots, _fn_io_set_device_filename, fn_io_buffer, fn_io_deviceslots, mod_devices_show_list_num
        .import     s_empty
        .import     sl_list_num
        .import     mod_hosts_show_list_num
        .import     mh_h1, mh_s1, mh_s3
        .import     md_h1, md_s1, md_s3
        .import     kb_mod_proc, p_current_line
        .import     hl_x_offset, _fn_clr_help, clear_box1, clear_box2
        .import     debug

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

;  handle HOST LIST
.proc mod_hosts
        jsr     _fn_clrscr
        put_status #0, #mh_s1
        put_status #1, #mh_s3
        put_help #1, #mh_h1

        ; do we have hosts data read?
        lda     hosts_fetched
        bne     :+

        jsr     _fn_io_get_host_slots
        mva     #$01, hosts_fetched

:       ; display hosts
        jsr     display_hosts

        ; do we have devices data read?
        lda     devices_fetched
        bne     :+

        jsr     _fn_io_get_device_slots
        mva     #$01, devices_fetched

        ; display devices
:       jsr     display_devices

        ; highlight current host entry
        mva     host_selected, current_line
        jsr     _fn_highlight_line

        ; handle keyboard
        pusha   #7              ; only 8 entries on screen
        pusha   #Mod::done      ; prev
        pusha   #Mod::devices   ; next
        pushax  #host_selected  ; memory address of our current host so it can be updated
        setax   #mod_hosts_kb   ; hosts kb handler
        jmp     kb_global          ; rts from this will drop out of module

.endproc

.proc display_hosts
        jsr     clear_box1
        pusha   #$00
        pushax  #mod_hosts_show_list_num
        pusha   #.sizeof(HostSlot)
        setax   #fn_io_hostslots
        jmp     show_list
.endproc

.proc display_devices
        jsr     clear_box2
        pusha   #$0C
        pushax  #mod_devices_show_list_num
        pusha   #.sizeof(DeviceSlot)
        setax   #fn_io_deviceslots+2    ; string is 2 chars in the struct
        jmp     show_list
.endproc


; ----------------------------------------------------------------------
; HOSTS KB HANDLER
; ----------------------------------------------------------------------
.proc mod_hosts_kb
; ----------------------------------------------------------------------
; E - EDIT
; ----------------------------------------------------------------------
        cmp     #'E'
        bne     not_edit
        jsr     _fn_edit_hosts_entry

        ldx     #KBH::RELOOP
        rts

not_edit:
; ----------------------------------------------------------------------
; RETURN - Browse Disk Images of selected HOST
; ----------------------------------------------------------------------
        cmp     #FNK_ENTER
        bne     not_eol

        mva     #$00, hl_x_offset

        ; set module to 'files' to show entries of chosen host
        lda     #Mod::files
        sta     mod_current

        ldx     #KBH::EXIT
        rts

not_eol:
; ----------------------------------------------------------------------
; TAB - Jump to Devices handler
; ----------------------------------------------------------------------
        cmp     #FNK_TAB
        bne     not_tab

        ; switch over to the devices box
        ; we're in a global kb handler that just calls into a mod specific handler.
        ; we should change that handler and change the current highlighting line, and set an offset to the lower box

        jsr     _fn_clr_help
        put_help #1, #md_h1

        mva     device_selected, current_line
        mva     #$30, hl_x_offset
        jsr     _fn_highlight_line

        mwa     #mod_devices_kb, kb_mod_proc
        mwa     #device_selected, p_current_line
        ; jsr     debug
        ldx     #KBH::RELOOP
        rts
not_tab:
; ----------------------------------------------------------------------
; EXIT - didn't handle it
; ----------------------------------------------------------------------
        ldx     #KBH::NOT_HANDLED
        rts
.endproc


.proc mod_devices_kb
; ----------------------------------------------------------------------
; Eject - remove current device
; ----------------------------------------------------------------------
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

        jsr     display_devices

        ldx     #KBH::RELOOP
        rts

not_eject:
; ----------------------------------------------------------------------
; TAB - Jump to Hosts handler
; ----------------------------------------------------------------------
        cmp     #FNK_TAB
        bne     not_tab

        jsr     _fn_clr_help
        put_help #1, #mh_h1

        mva     host_selected, current_line
        mva     #$00, hl_x_offset
        jsr     _fn_highlight_line

        mwa     #mod_hosts_kb, kb_mod_proc
        mwa     #host_selected, p_current_line
        ldx     #KBH::RELOOP
        rts

not_tab:

        ldx     #KBH::NOT_HANDLED
        rts

.endproc

.data
hosts_fetched:          .byte 0
host_selected:          .byte 0
device_selected:        .byte 0
devices_fetched:        .byte 0
