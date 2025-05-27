        .export     mfp_show_page
        .export     mfp_pg_buf

        .export     mfp_start_pg_ptr
        .export     mfp_current_entry
        .export     mfp_is_last_group
        .export     mfp_num_entries
        .export     mfp_e_is_dir

        .import     _page_cache_get_pagegroup
        .import     _page_cache_set_path_filter
        .import     ts_to_datestr
        .import     ts_output

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
        ; mfp_pg_buf contains JUST THE PAGE GROUP ENTRY DATA, so from byte 5 in the following

        ;  * PageGroup Entry structure:
        ;  *  Each entry:
        ;  *  - Bytes 0-3: Packed timestamp and flags
        ;  *              - Byte 0: Years since 1970 (0-255)
        ;  *              - Byte 1: FFFF MMMM (4 bits flags, 4 bits month 1-12)
        ;  *                       Flags: bit 7 = directory, bit 6 = last entry in group (1=yes), bits 5-4 reserved
        ;  *              - Byte 2: DDDDD HHH (5 bits day 1-31, 3 high bits of hour)
        ;  *              - Byte 3: HH mmmmmm (2 low bits hour 0-23, 6 bits minute 0-59)
        ;  *  - Bytes 4-6: File size (24-bit little-endian, 0 for directories)
        ;  *  - Byte  7  : Media type (0-255, with 0=unknown) - could be used for interesting icons
        ;  *  - Bytes 8+ : Null-terminated filename

        ; HOW DO WE KNOW HOW MANY ENTRIES ARE IN THIS PAGEGROUP? we only get the pagegroup data returned, not
        ; the header bytes
        ; ANSWER: Bit 6 of the flags is 1 if the entry is the last one in the page group

        mva     #$00, mf_entry_index

        mwa     mfp_pg_buf, mfp_current_entry

loop_entries:
        ; move mfp_current_entry into ptr1 so we can use indirection
        mwa     mfp_current_entry, ptr1

        ; TODO: we only need this for the 1st entry.
        ; Later when using arrow keys highlighting different entries, we will call the appropriate routines for the highlighted entry
        ; OR: we stash the timestamps and sizes into memory here once, and the highlighting only needs to read from the cached values

        ; Get timestamp string - ptr1 already points to the 4 timestamp bytes
        lda     ptr1            ; Low byte of address
        ldx     ptr1+1         ; High byte of address
        jsr     ts_to_datestr  ; Result will be in ts_output

        ; Check if this is last entry in group (bit 6 of byte 1)
        ldy     #1              ; Byte 1 contains flags in upper nibble
        lda     (ptr1),y
        and     #%01000000     ; Bit 6 = last entry flag
        sta     mfp_is_last_group

        ; Check if it's a directory (bit 7 of byte 1)
        lda     (ptr1),y
        and     #%10000000     ; Bit 7 = directory flag
        sta     mfp_e_is_dir

        ; Get filesize (bytes 4-6, 24-bit little endian)
        ldy     #4
        lda     (ptr1),y       ; Low byte
        sta     tmp1
        iny
        lda     (ptr1),y       ; Middle byte
        sta     tmp2           ; tmp2 is next byte after tmp1
        iny
        lda     (ptr1),y       ; High byte
        sta     tmp3           ; tmp3 is next byte after tmp2

        ; TODO: use strlen, and allow for longer than 256 bytes? Also, we can only go to 256-8 because of Y starting at 8
        ; Find length of filename to know how far to advance
        ldy     #8              ; Start of filename
        ldx     #0              ; Will count length
@find_end:
        lda     (ptr1),y
        beq     @got_length
        iny
        inx
        bne     @find_end      ; Safety check - don't loop forever
@got_length:
        ; Y now points at the nul byte
        ; Total entry length = 8 (header) + filename length + 1 (nul)
        tya
        sec
        adc     mfp_current_entry    ; Add low byte
        sta     mfp_current_entry
        bcc     :+
        inc     mfp_current_entry+1  ; Handle carry to high byte

:       ; Check if this was the last entry
        lda     mfp_is_last_group
        bne     done

        inc     mf_entry_index
        jmp     loop_entries

done:   
        rts

.bss
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