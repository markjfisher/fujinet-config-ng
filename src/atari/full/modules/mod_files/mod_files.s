        .export     _mod_files

        .import     _mf_init_screen
        .import     mfs_main

.segment "CODE2"

.proc _mod_files
        jsr     _mf_init_screen

        ; this is "mod files - simple", more complex block reading not yet implemented
        jmp     mfs_main
.endproc
