        .export     mod_hosts, hosts_fetched, host_selected
        .import     _fn_io_get_host_slots, fn_io_hostslots, _dev_highlight_line, mod_kb, current_line
        .import     pusha, pushax, show_list, _dev_edit_hosts_entry
        .import     _fn_clrscr, _fn_put_help
        .import     s_empty, s_hosts_h1, s_hosts_h2, s_hosts_h3
        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

;  handle HOST LIST
.proc mod_hosts
        jsr     _fn_clrscr
        put_help #0, #s_hosts_h1
        put_help #1, #s_hosts_h2
        put_help #2, #s_hosts_h3

        ; do we have hosts data read?
        lda     hosts_fetched
        bne     :+

        jsr     _fn_io_get_host_slots
        mva     #$01, hosts_fetched

:
        jsr     display_hosts

        ; highlight current host entry
        mva     host_selected, current_line
        jsr     _dev_highlight_line

        ; handle keyboard
        pusha   #7              ; only 8 entries on screen
        pusha   #Mod::done      ; prev
        pusha   #Mod::devices   ; next
        pushax  #host_selected  ; memory address of our current host so it can be updated
        setax   #mod_hosts_kb   ; hosts kb handler
        jmp     mod_kb          ; rts from this will drop out of module

display_hosts:
        pusha   #.sizeof(HostSlot)
        setax   #fn_io_hostslots
        jmp     show_list
        ; implicit rts

; the local module's keyboard handling routines
mod_hosts_kb:
        ; A contains the key pressed
        cmp     #'E'    ; Edit current field
        bne     :+

        ; matched "E", so edit current entry
        jsr     _dev_edit_hosts_entry

:

        ; all module specific codes checked, return to main kb handler
        rts

.endproc

.bss
host_index:     .res 1

.data
hosts_fetched:  .byte 0
host_selected: .byte 0