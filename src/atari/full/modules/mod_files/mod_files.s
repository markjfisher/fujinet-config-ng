        .export     _mod_files

        .import     _bank_count
        .import     _cng_prefs
        .import     _mf_init_screen
        .import     mfp_main
        .import     mfs_main

        .include    "cng_prefs.inc"

.proc _mod_files
        jsr     _mf_init_screen

        ; Choose between simple and paging version based on available banked RAM, and user prefs
        lda     _bank_count
        beq     use_simple      ; No banks available - use simple version

        lda     _cng_prefs + CNG_PREFS_DATA::use_banks
        beq     use_simple      ; did user enable banks? 1=yes, 0=no

        ; Banks available, and user enabled - use paging version with cache
        jmp     mfp_main

use_simple:
        ; No banked RAM - use simple version
        jmp     mfs_main
.endproc
