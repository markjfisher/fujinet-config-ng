        .export     _mod_info

        .import     _mi_handle_input
        .import     _mi_init_screen

.proc _mod_info
        jsr     _mi_init_screen
        jmp     _mi_handle_input
.endproc
