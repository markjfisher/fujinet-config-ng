        .export     mfp_show_page
        .export     mfp_pg_buf

        .import     _page_cache_get_pagegroup
        .import     _page_cache_set_path_filter

        .import     _get_pagegroup_params
        .import     _set_path_flt_params

        .import     fn_dir_filter
        .import     fn_dir_path
        .import     mf_dir_pos
        .import     mf_dir_pg_cnt

        .import     debug

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "page_cache.inc"

.segment "CODE2"

mfp_show_page:
;  store pagegroup we're on
;  ask cache for this pagegroup (check for error)
;  parse the data for pagegroup from returned memory location for the page
;  display this pages list of files

; when the cursor/selection is on a particular file
;   - <scroll> it to make it visible over whole name - NEED NEW ANIMATION
;   - print its file size and date in the extra line

        ; set the path_hash - TODO: move this to where it's not constantly called
        mwa     #fn_dir_path, _set_path_flt_params+page_cache_set_path_filter_params::path
        mwa     #fn_dir_filter, _set_path_flt_params+page_cache_set_path_filter_params::filter
        jsr     debug
        jsr     _page_cache_set_path_filter

        ; setup the get call's parameters
        mwa     mf_dir_pos, _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        ; THESE 2 CAN BE SETUP IN INIT
        mva     mf_dir_pg_cnt, _get_pagegroup_params+page_cache_get_pagegroup_params::page_size
        mwa     #mfp_pg_buf, _get_pagegroup_params+page_cache_get_pagegroup_params::data_ptr

        ; get the pagegroup! FINALLY!
        jsr     debug
        jsr     _page_cache_get_pagegroup
        jsr     debug

        ; now display it, the raw page group data is in mfp_pg_buf

        



        rts




.bss
; this is where the cache copies the current pagegroup data to. just 1 pagegroup (i.e. screen's data for all files and their file sizes etc)
; NOTE: this can't be in BANK as the cache is copying out of cache which is in RAM BANK
; and can't copy into normal memory BANK as they can't be active at same time
mfp_pg_buf:     .res 2048
