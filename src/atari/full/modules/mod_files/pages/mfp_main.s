        .export     mfp_main

        .import     kb_cb_function
        .import     kb_current_line
        .import     mf_selected
        .import     mf_init
        .import     mod_current

        .import     mf_dir_pg_cnt

        .import     mf_error_initialising
        .import     mf_error_opening_page
        .import     mf_handle_input
        .import     mf_kbh_running

        .import     mfp_new_page
        .import     mfp_pg_buf
        .import     mfp_show_page

        .import     _bank_count
        .import     _get_pagegroup_params
        .import     _page_cache_init

        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "modules.inc"
        .include    "page_cache.inc"

.segment "CODE2"

; page group reading
.proc mfp_main
        jsr     mf_init                         ; identical setup to simple files - 
        bne     init_ok                         ; success status returned by mf_init

        jsr     mf_error_initialising
        mva     #Mod::hosts, mod_current
        rts

init_ok:
        lda     _bank_count
        jsr     _page_cache_init                ; setup the cache free bank sizes etc.

        ; TODO: make cache init return status and error if there were issues
        ; 16 files/dirs per page
        mva     #16, mf_dir_pg_cnt
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::page_size
        mwa     #mfp_pg_buf, _get_pagegroup_params+page_cache_get_pagegroup_params::data_ptr

        ; no call back for now
        lda     #$00
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::fetching_cb
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::fetching_cb+1

file_loop:
        jsr     mfp_new_page
        beq     page_ok
        jmp     mf_error_opening_page

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
        ; reset the kb cb routine to nothing so next screen using a global kb handler doesn't get odd effects
        lda     #$00
        sta     kb_cb_function
        sta     kb_cb_function+1

        rts

.endproc
