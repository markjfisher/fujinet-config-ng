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
        .import     mf_entry_index
        .import     mf_selected

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
        ;  *              - Byte  7  : Media type (0-255, with 0=unknown) - could be used for interesting icons
        ;  *              - Bytes 8+ : Null-terminated filename

        mva     #$00, mf_entry_index
        adw     mfp_pg_buf, #$05, mfp_current_entry

        ; check flags for EOD
        lda     mfp_pg_buf
        and     #$80
        sta     mfp_is_last_group

        ; capture the number of entries in this group. it'll be page_size, or potentially less if EOD
        lda     mfp_pg_buf+1
        sta     mfp_num_entries

        ; do we need the pagegroup data size? we don't move over pages here
        ; mwa     mfp_pg_buf+2, mfp_pagegroup_size

        ; capture the pagegroup index - do we need this?
        ; lda     mfp_pg_buf+4, mfp_current_pg_idx

        ; start_pg_ptr    = pointer to start of pagegroup, doesn't increment, as we are only displaying 1 pagegroup, this is just #mfp_pg_buf
        ; current_entry   = pointer to current entry, starts at start_pg_ptr+5, increases by 8+strlen(filename)
loop_entries:
        ; move mfp_current_entry into ptr1 so we can use indirection, as it is dynamic
        mwa     mfp_current_entry, ptr1
        ; mf_selected is 0 based currently selected line, mf_entry_index is the loop index we're currently displaying
        ; the animation doesn't start until after we print this page anyway, so we don't need to special case it here

        ; deal with the time

        rts

.bss
mfp_start_pg_ptr:       .res 2
mfp_current_entry:      .res 2
mfp_is_last_group:      .res 1
mfp_num_entries:        .res 1
; mfp_current_pg_idx:     .res 1          ; the pagegroup number (0, 1, 2, ...) used in cache index
; entry data
mfp_e_is_dir:           .res 1

; this is where the cache copies the current pagegroup data to. just 1 pagegroup (i.e. screen's data for all files and their file sizes etc)
; NOTE: this can't be in BANK as the cache is copying out of cache which is in RAM BANK
; and can't copy into normal memory BANK as they can't be active at same time
mfp_pg_buf:             .res 2048