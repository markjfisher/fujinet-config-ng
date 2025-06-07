        .export     mfp_main
        .export     mfp_update_selection_display

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
        .import     mfp_timestamp_cache
        .import     mfp_filesize_cache
        .import     mf_dir_or_file
        .import     mf_kb_cb_reset_anim
        .import     mf_kb_cb

        .import     _bank_count
        .import     _get_pagegroup_params
        .import     _page_cache_init
        .import     kb_selection_changed_cb
        .import     _put_s

        .include    "zp.inc"
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
        
        ; Set up selection changed callback for updating timestamp/filesize display
        mwa     #mfp_update_selection_display, kb_selection_changed_cb

file_loop:
        jsr     mfp_new_page
        beq     page_ok
        jmp     mf_error_opening_page

page_ok:
        jsr     mfp_show_page

        ; Set up animation callback for scrolling long filenames, we can do this once page loaded as we then have all the file names
        mwa     #mf_kb_cb, kb_cb_function

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

        ; Clear selection changed callback
        sta     kb_selection_changed_cb
        sta     kb_selection_changed_cb+1

        rts

.endproc

; Callback function to update timestamp and filesize display when selection changes
.proc mfp_update_selection_display
        ; Reset filename scrolling animation
        jsr     mf_kb_cb_reset_anim
        
        ; Calculate offset into timestamp cache: mf_selected * 17
        lda     mf_selected
        asl     a               ; * 2
        asl     a               ; * 4  
        asl     a               ; * 8
        asl     a               ; * 16
        clc
        adc     mf_selected     ; + 1 = * 17
        clc
        adc     #<mfp_timestamp_cache
        sta     ptr1
        lda     #>mfp_timestamp_cache
        adc     #0              ; add carry
        sta     ptr1+1
        
        ; Print timestamp at position (1, 21)
        put_s   #01, #21, ptr1

        ; Check if selected entry is a directory
        ldx     mf_selected
        lda     mf_dir_or_file,x
        beq     show_size

        ; It's a directory, show spaces instead
        put_s   #27, #21, #dir_spaces
        rts

show_size:
        ; Calculate offset into filesize cache: mf_selected * 11
        lda     mf_selected
        asl     a               ; * 2
        asl     a               ; * 4
        asl     a               ; * 8
        clc
        adc     mf_selected     ; + 1 = * 9
        adc     mf_selected     ; + 1 = * 10  
        adc     mf_selected     ; + 1 = * 11
        clc
        adc     #<mfp_filesize_cache
        sta     ptr1
        lda     #>mfp_filesize_cache
        adc     #0              ; add carry
        sta     ptr1+1
        
        ; Print filesize at position (27, 21)
        put_s   #27, #21, ptr1
        rts

.data
dir_spaces:     .byte "          ",0     ; 10 spaces for directory entries

.endproc
