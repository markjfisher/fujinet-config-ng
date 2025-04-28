        .export     _mod_files

        .import     _mf_init_screen
        .import     mfp_main
        .import     mfs_main

.proc _mod_files
        jsr     _mf_init_screen

        ; this is "mod files - simple", more complex block reading not yet implemented
        jmp     mfs_main
        
        ; shiny new "mod files - paging" - eventually make this picked from config
        ; jmp     mfp_main
        ; rts
.endproc
