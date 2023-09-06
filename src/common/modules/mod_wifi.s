        .export     _mod_wifi

        .import     _mw_display_wifi
        .import     _mw_get_wifi_data
        .import     _mw_handle_input
        .import     _mw_init_screen

.proc _mod_wifi
        jsr     _mw_init_screen
        jsr     _mw_get_wifi_data
        jsr     _mw_display_wifi
        ; jmp     _mw_handle_input
        rts
.endproc
