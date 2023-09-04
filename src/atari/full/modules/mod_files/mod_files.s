        .export     mod_files

        .import     _mf_init_screen
        .import     mfs_main

.proc mod_files
        jsr     _mf_init_screen

        jmp     mfs_main
.endproc
