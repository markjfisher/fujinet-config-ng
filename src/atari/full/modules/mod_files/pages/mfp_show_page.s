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

        ; set the path_hash - TODO: move this to where it's not constantly called, and only when it changes
        mwa     #fn_dir_path, _set_path_flt_params+page_cache_set_path_filter_params::path
        mwa     #fn_dir_filter, _set_path_flt_params+page_cache_set_path_filter_params::filter
        jsr     _page_cache_set_path_filter

        ; setup the get call's parameters
        mwa     mf_dir_pos, _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position

        ; get the pagegroup
        jsr     _page_cache_get_pagegroup

        ; now display it, the raw page group data is in mfp_pg_buf

        ;  * PageGroup structure:
        ;  * Byte  0    : Flags
        ;  *              - Bit 7: Last group (1=yes, 0=no)
        ;  *              - Bits 6-0: Reserved
        ;  * Byte  1    : Number of directory entries in this group
        ;  * Bytes 2-3  : Group data size (16-bit little-endian, excluding header)
        ;  * Byte  4    : Group index (0-based, calculated as dir_pos/group_size)
        ;  * Bytes 5+   : File/Directory entries for this group
        ;  *              Each entry:
        ;  *              - Bytes 0-3: Packed timestamp and flags
        ;  *                          - Byte 0: Years since 1970 (0-255)
        ;  *                          - Byte 1: FFFF MMMM (4 bits flags, 4 bits month 1-12)
        ;  *                                   Flags: bit 7 = directory, bits 6-4 reserved
        ;  *                          - Byte 2: DDDDD HHH (5 bits day 1-31, 3 high bits of hour)
        ;  *                          - Byte 3: HH mmmmmm (2 low bits hour 0-23, 6 bits minute 0-59)
        ;  *              - Bytes 4-6: File size (24-bit little-endian, 0 for directories)
        ;  *              - Byte  7  : Media type (0-255, with 0=unknown)
        ;  *              - Bytes 8+ : Null-terminated filename

        mva     #$00, mf_entry_index

loop_entries:
        ldx     mf_entry_index
        lda     mfp_pg_buf

        ; we need to elipsize each entry as we print it, as fujinet sends entire filename when in block mode.
        ; then animate it when we're hovering over it. for now, just print them ellipsized

        ; filename is at mfp_pg_buf+5+8 initially, then we skip over to the next entry beyond the filename
        

        rts




.bss
; this is where the cache copies the current pagegroup data to. just 1 pagegroup (i.e. screen's data for all files and their file sizes etc)
; NOTE: this can't be in BANK as the cache is copying out of cache which is in RAM BANK
; and can't copy into normal memory BANK as they can't be active at same time
mfp_pg_buf:     .res 2048
