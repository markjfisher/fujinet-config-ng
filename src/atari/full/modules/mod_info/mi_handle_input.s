        .export     _mi_handle_input

        .import     kb_global

        .import     _mi_edit_preferences

        .import     kb_current_line
        .import     kb_max_entries
        .import     kb_prev_mod
        .import     kb_next_mod
        .import     kb_mod_current_line_p
        .import     kb_mod_proc

        .import     mi_selected
        .import     kb_selection_changed_cb

        .include    "fn_data.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "zp.inc"

.proc _mi_handle_input
        mva     mi_selected, kb_current_line

        ; count of preferences that can be altered (0 based)
        mva     #$08, kb_max_entries
        mva     #Mod::wifi, kb_prev_mod
        mva     #Mod::hosts, kb_next_mod
        mwa     #mi_selected, kb_mod_current_line_p
        mwa     #mi_kbh, kb_mod_proc

        jsr     kb_global      ; rts from this will drop out of module

        ; Clear the selection callback when leaving this module
        mwa     #$0000, kb_selection_changed_cb

        rts
.endproc

.proc mi_kbh

; ----------------------------------------------------------------------
; E - EDIT
; ----------------------------------------------------------------------
        cmp     #FNK_EDIT
        bne     not_edit
        jsr     _mi_edit_preferences

        ldx     #KBH::RELOOP
        rts

not_edit:
do_exit:
        ldx     #KBH::NOT_HANDLED
        rts
.endproc