        .export     mfp_main

        .import     kb_current_line
        .import     mf_selected
        .import     mfc_init
        .import     mod_current

        .import     mfc_error_initialising
        .import     mfs_error_opening_page
        .import     mf_handle_input
        .import     mf_kbh_running
        .import     mfp_new_page
        .import     mfp_show_page


        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "modules.inc"

.segment "CODE2"

; page group reading
.proc mfp_main
        jsr     mfc_init                        ; identical setup to simple files - 
        bne     init_ok                       ; success status returned by mfp_init

        jsr     mfc_error_initialising
        mva     #Mod::hosts, mod_current
        rts

init_ok:

file_loop:
        jsr     mfp_new_page
        beq     page_ok
        jmp     mfs_error_opening_page

page_ok:
        jsr     mfp_show_page
        mva     mf_selected, kb_current_line
        jsr     mf_handle_input

        cpx     #KBH::EXIT
        beq     exit_mfp

        ; reloop until hit an exit condition from kbh
        mva     #$00, mf_kbh_running
        beq     file_loop

exit_mfp:
        rts

.endproc
