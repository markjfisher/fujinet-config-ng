        .export     _mod_devices

        .import     _md_display_devices
        .import     _md_get_devices_data
        .import     _md_handle_input
        .import     _md_init_screen

.proc _mod_devices
        jsr     _md_init_screen
        jsr     _md_get_devices_data
        jsr     _md_display_devices
        jmp     _md_handle_input
.endproc
