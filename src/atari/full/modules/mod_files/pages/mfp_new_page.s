        .export     mfp_new_page

        .import     _clr_help
        .import     _clr_scr_with_separator
        .import     _fuji_error
        .import     _fuji_open_directory
        .import     _fuji_set_directory_position
        .import     _get_pagegroup_params
        .import     _page_cache_check_exists
        .import     _page_cache_set_path_filter
        .import     _put_help
        .import     _put_status
        .import     _scr_clr_highlight
        .import     _set_path_flt_params
        .import     copy_path_filter_to_buffer
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     fuji_buffer
        .import     mf_copying
        .import     mf_copying_msg
        .import     mf_dir_pg_cnt
        .import     mf_dir_pos
        .import     mf_h1
        .import     mf_s1
        .import     mf_is_eod
        .import     mh_host_selected
        .import     mf_print_dir_info
        .import     pusha
        .import     return1
        .import     screen_separators
        .import     debug

        .include    "zp.inc"
        .include    "page_cache.inc"
        .include    "macros.inc"

.segment "CODE2"

; set up the screen for a new page of files, getting screen ready and buffer with current path, and attempt to open the directory
; ptr1
.proc mfp_new_page
        ; setup separator lines, and draw border. 0 based index for border line
        mva     #3, screen_separators
        ; allows 16 lines in file list (4-19), and 1 in an extra line for Date/Size information for current file
        mva     #20, screen_separators+1
        ldy     #$02
        ; redraw page with separator
        jsr     _clr_scr_with_separator

        jsr     _clr_help
        put_status #0, #mf_s1
        put_help   #0, #mf_h1

        lda     mf_copying
        beq     :+
        put_status #1, #mf_copying_msg          ; need to UNDO this text when we are no longer copying

:       mva     #$00, mf_is_eod
        jsr     _scr_clr_highlight
        jsr     mf_print_dir_info
        jsr     copy_path_filter_to_buffer

        ; -----------------------------------------------------
        ; Check cache first - only call FujiNet if we need new data

        ; Set up path hash for cache lookup
        mwa     #fn_dir_path, _set_path_flt_params+page_cache_set_path_filter_params::path
        mwa     #fn_dir_filter, _set_path_flt_params+page_cache_set_path_filter_params::filter
        jsr     _page_cache_set_path_filter

        ; Set up parameters for cache check (same as get_pagegroup would use)
        mwa     mf_dir_pos, _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        mva     mf_dir_pg_cnt, _get_pagegroup_params+page_cache_get_pagegroup_params::page_size

        ; Check if pagegroup exists in cache (also validates boundary)
        jsr     _page_cache_check_exists
        beq     cache_hit       ; A == 0 means found, skip FujiNet calls
        cmp     #2
        beq     error_exit      ; A == 2 means boundary error
        ; A == 1 means cache miss, continue to FujiNet calls

cache_miss:
        ; Cache miss - need to call FujiNet functions
        ; -----------------------------------------------------
        ; open directory
        pusha   mh_host_selected
        setax   #fuji_buffer
        jsr     _fuji_open_directory

        jsr     _fuji_error
        bne     error_exit

        ; all good, set the dir pos, and return dir pos status
        setax   mf_dir_pos
        jsr     _fuji_set_directory_position
        ; did it fail?
        jsr     _fuji_error
        bne     error_exit

cache_hit:
        ; Cache hit or successful FujiNet setup - return success
        lda     #$00
        rts

error_exit:
        ; FujiNet error occurred
        jmp     return1
.endproc
