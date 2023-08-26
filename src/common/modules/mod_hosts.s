        .export     mod_hosts, hosts_fetched, host_selected
        .import     _fn_io_get_host_slots, fn_io_hostslots, _fn_highlight_line, kb_global, current_line
        .import     pusha, pushax, show_list, _fn_edit_hosts_entry, mod_current
        .import     _fn_clrscr, _fn_put_help, _fn_put_status
        .import     s_empty
        .import     sl_list_num
        .import     mod_hosts_show_list_num
        .import     mh_h1, mh_s1, mh_s3
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

:       jsr     display_hosts

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

display_hosts:
        pushax  #mod_hosts_show_list_num
        pusha   #.sizeof(HostSlot)
        setax   #fn_io_hostslots
        jmp     show_list
        ; implicit rts

; ----------------------------------------------------------------------
; HOSTS KB HANDLER
; ----------------------------------------------------------------------
mod_hosts_kb:
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
        ; set module to 'files' to show entries of chosen host
        lda     #Mod::files
        sta     mod_current

        ldx     #KBH::EXIT
        rts

not_eol:
; ----------------------------------------------------------------------
; EXIT - didn't handle it
; ----------------------------------------------------------------------
        ldx     #KBH::NOT_HANDLED
        rts

.endproc

.bss
host_index:     .res 1

.data
hosts_fetched:  .byte 0
host_selected:  .byte 0
