        .export     _mod_files

        .import     _mf_init_screen
        .import     mfp_main
        .import     mfs_main
        .import     _bank_count

.proc _mod_files
        jsr     _mf_init_screen

        ; Choose between simple and paging version based on available banked RAM
        lda     _bank_count
        beq     use_simple      ; No banks available - use simple version

        ; Banks available - use paging version with cache
        jmp     mfp_main

use_simple:
        ; No banked RAM - use simple version
        jmp     mfs_main
.endproc
