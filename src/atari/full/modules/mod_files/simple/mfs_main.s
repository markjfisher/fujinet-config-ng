        .export     mfs_main

        .import     kb_current_line
        .import     mf_selected
        .import     mfs_error_initialising
        .import     mfs_error_opening_page
        .import     mfs_handle_input
        .import     mfs_init
        .import     mfs_kbh_running
        .import     mfs_new_page
        .import     mfs_show_page

        .include    "fc_macros.inc"
        .include    "fn_data.inc"
        .include    "fc_mods.inc"

; same as original implementation, reads dirs 1 by 1
.proc mfs_main
        jsr     mfs_init
        beq     file_loop                       ; 0 indicates no error
        jmp     mfs_error_initialising

; we'll keep looping around here until something is chosen, or we exit
file_loop:
        jsr     mfs_new_page
        beq     page_ok
        jmp     mfs_error_opening_page

page_ok:
        jsr     mfs_show_page
        mva     mf_selected, kb_current_line
        jsr     mfs_handle_input

        cpx     #KBH::EXIT
        beq     exit_mfs

        ; reloop until hit an exit condition from kbh
        mva     #$00, mfs_kbh_running
        beq     file_loop

exit_mfs:
        rts

.endproc
