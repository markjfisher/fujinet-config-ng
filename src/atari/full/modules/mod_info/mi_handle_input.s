        .export     _mi_handle_input

        .import     kb_global

        .import     kb_current_line
        .import     kb_max_entries
        .import     kb_prev_mod
        .import     kb_next_mod
        .import     kb_mod_current_line_p
        .import     kb_mod_proc

        .import     mi_selected
        .import     pusha
        .import     pushax

        .include    "macros.inc"
        .include    "modules.inc"
        .include    "zp.inc"

.proc _mi_handle_input
        ; handle keyboard

        mva     #$00, kb_max_entries
        mva     #Mod::wifi, kb_prev_mod
        mva     #Mod::hosts, kb_next_mod
        mwa     #mi_selected, kb_mod_current_line_p
        mwa     #mi_kbh, kb_mod_proc

        jmp     kb_global      ; rts from this will drop out of module
.endproc

.proc mi_kbh
        rts
.endproc