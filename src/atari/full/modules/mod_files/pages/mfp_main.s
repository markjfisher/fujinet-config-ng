        .export     mfp_main

        .import     kb_current_line
        .import     mf_selected
        .import     mfc_init
        .import     mod_current

        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "modules.inc"

.segment "CODE2"

; page group reading
.proc mfp_main
        jsr     mfc_init                        ; identical setup to simple files - 
        bne     init_ok                       ; success status returned by mfp_init

        ; jsr     mfp_error_initialising
        mva     #Mod::hosts, mod_current
        rts

init_ok:


exit_mfp:
        rts

.endproc
