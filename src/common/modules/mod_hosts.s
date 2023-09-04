        .export     _mod_hosts

        .import     _mh_display_hosts
        .import     _mh_get_hosts_data
        .import     _mh_handle_input
        .import     _mh_init_screen

.proc _mod_hosts
        jsr     _mh_init_screen
        jsr     _mh_get_hosts_data
        jsr     _mh_display_hosts
        jmp     _mh_handle_input
.endproc
