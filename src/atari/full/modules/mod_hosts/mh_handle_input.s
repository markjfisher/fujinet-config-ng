        .export     _mh_handle_input
        .export     mh_kb_handler

        .import     _edit_hosts_entry
        .import     kb_global

        .import     kb_current_line
        .import     kb_max_entries
        .import     kb_prev_mod
        .import     kb_next_mod
        .import     kb_mod_current_line_p
        .import     kb_mod_proc

        .import     _scr_highlight_line
        .import     get_to_current_hostslot
        .import     mh_host_selected
        .import     mod_current

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "modules.inc"

.proc _mh_handle_input
        mva     mh_host_selected, kb_current_line

        mva     #$07, kb_max_entries
        mva     #Mod::info, kb_prev_mod
        mva     #Mod::devices, kb_next_mod
        mwa     #mh_host_selected, kb_mod_current_line_p
        mwa     #mh_kb_handler, kb_mod_proc

        jmp     kb_global      ; rts from this will drop out of module

.endproc


.proc mh_kb_handler
; ----------------------------------------------------------------------
; E - EDIT
; ----------------------------------------------------------------------
        cmp     #FNK_EDIT
        bne     not_edit
        jsr     _edit_hosts_entry

        ldx     #KBH::RELOOP
        rts

not_edit:
; ----------------------------------------------------------------------
; RETURN - Browse Disk Images of selected HOST
; ----------------------------------------------------------------------
        cmp     #FNK_ENTER
        bne     not_eol

        ; does the chosen host have an actual entry? if it's empty, ignore the keypress
        ; set ptr1 to the currently selected host slot
        jsr     get_to_current_hostslot
        ldy     #$00
        lda     (ptr1), y               ; first byte of the host name, empty string is 0
        beq     do_exit     

        ; set module to 'files' to show entries of chosen host. the files module will timeout if the host is rubbish, and will show errors etc, but we aren't concerned with that here.
        mva     #Mod::files, mod_current
        ldx     #KBH::EXIT
        rts

not_eol:
; -------------------------------------------------
; 1-8
        cmp     #'1'
        bcs     one_or_over
        bcc     not_1_max
one_or_over:
        cmp     #('1' + MAX_HOSTS)
        bcs     not_1_max

        ; in range 1-8
        sec
        sbc     #'1' ; convert to 0 based index
        sta     mh_host_selected
        sta     kb_current_line         ; tell global kb handler the latest value too
        ; jsr     _scr_highlight_line
        ldx     #KBH::RELOOP
        rts

not_1_max:
; ----------------------------------------------------------------------
; EXIT - didn't handle it
; ----------------------------------------------------------------------
do_exit:
        ldx     #KBH::NOT_HANDLED
        rts

.endproc