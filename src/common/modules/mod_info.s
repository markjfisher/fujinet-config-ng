        .export     _mod_info

        .import     _mi_display_prefs
        .import     _mi_handle_input
        .import     _mi_init_screen

.proc _mod_info
        ; show the non-editable data
        jsr     _mi_init_screen

        ; show the editable preferences
        jsr     _mi_display_prefs
        jmp     _mi_handle_input
.endproc
