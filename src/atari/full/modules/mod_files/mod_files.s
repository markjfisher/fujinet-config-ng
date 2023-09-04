        .export     mod_files

        .import     _mf_init_screen
        .import     files_simple

.proc mod_files
        jsr     _mf_init_screen

        jmp     files_simple
.endproc
