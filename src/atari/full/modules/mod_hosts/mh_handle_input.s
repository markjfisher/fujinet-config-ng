        .export     _mh_handle_input

        .import     _edit_hosts_entry
        .import     _kb_global
        .import     _scr_highlight_line
        .import     kb_current_line
        .import     mh_host_selected
        .import     mod_current
        .import     pusha
        .import     pushax

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

.proc _mh_handle_input
        mva     mh_host_selected, kb_current_line

        pusha   #7              ; only 8 entries on screen
        pusha   #Mod::done      ; prev
        pusha   #Mod::devices   ; next
        pushax  #mh_host_selected  ; memory address of our current host so it can be updated
        setax   #mh_kb_handler  ; hosts kb handler
        jmp     _kb_global      ; rts from this will drop out of module

.endproc


.proc mh_kb_handler
; ----------------------------------------------------------------------
; E - EDIT
; ----------------------------------------------------------------------
        cmp     #'E'
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
        ; set module to 'files' to show entries of chosen host
        mva     #Mod::files, mod_current

        ldx     #KBH::EXIT
        rts

not_eol:
; -------------------------------------------------
; 1-8
        cmp     #'1'
        bcs     one_or_over
        bcc     not_1_8
one_or_over:
        cmp     #'9'
        bcs     not_1_8

        ; in range 1-8
        sec
        sbc     #'1' ; convert from ascii for 1-8 to index 0-7
        sta     mh_host_selected
        sta     kb_current_line         ; tell global kb handler the latest value too
        jsr     _scr_highlight_line
        ldx     #KBH::RELOOP
        rts

not_1_8:
; ----------------------------------------------------------------------
; EXIT - didn't handle it
; ----------------------------------------------------------------------
        ldx     #KBH::NOT_HANDLED
        rts

.endproc