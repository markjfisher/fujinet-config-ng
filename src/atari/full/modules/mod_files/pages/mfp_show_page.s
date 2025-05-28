        .export     mfp_show_page
        .export     mfp_pg_buf

        ;.export     mfp_start_pg_ptr
        .export     mfp_current_entry
        .export     mfp_is_last_group
        .export     mfp_e_is_dir

        .export     mfp_timestamp_cache
        .export     mfp_filesize_cache
        .export     mfp_filename_cache

        .import     _page_cache_get_pagegroup
        .import     _page_cache_set_path_filter
        .import     ts_to_datestr
        .import     ts_output
        .import     size_to_str
        .import     size_output

        .import     _fc_strlen
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


        ; Initialize cache pointers
        mwa     #mfp_timestamp_cache, mfp_ts_cache_ptr
        mwa     #mfp_filesize_cache, mfp_size_cache_ptr
        mwa     #mfp_filename_cache, mfp_fname_cache_ptr

        ; TODO: why do we touch this at all?
        mva     #$00, mf_entry_index
        mwa     #mfp_pg_buf, mfp_current_entry

loop_entries:
        jsr     debug
        lda     mfp_current_entry
        ldx     mfp_current_entry+1
        sta     ptr1
        stx     ptr1+1

        ; Get timestamp string - ptr1 already points to the 4 timestamp bytes
        jsr     ts_to_datestr  ; Result will be in ts_output

        ; Cache the timestamp string using ptr2
        mwa     mfp_ts_cache_ptr, ptr2
        ldy     #15             ; Copy 16 bytes (without nul)
:       lda     ts_output,y
        sta     (ptr2),y
        dey
        bpl     :-
        
        ; Advance timestamp cache pointer by 16
        adw     mfp_ts_cache_ptr, #16

        ; Check if this is last entry in group (bit 6 of byte 1)
        ldy     #$01            ; Byte 1 contains flags in upper nibble
        lda     (ptr1),y
        and     #%01000000      ; Bit 6 = last entry flag
        sta     mfp_is_last_group

        ; Check if it's a directory (bit 7 of byte 1)
        lda     (ptr1),y
        and     #%10000000     ; Bit 7 = directory flag
        sta     mfp_e_is_dir


        ; Convert size to string (right justified)
        adw     ptr1, #$04
        mwa     ptr1, tmp5
        setax   ptr1
        ldy     #1              ; Right justify
        jsr     size_to_str     ; Result will be in size_output - trashes ptr1-4 via memmove
        mwa     tmp5, ptr1      ; restore ptr1

        ; Cache the size string
        mwa     mfp_size_cache_ptr, ptr2
        ldy     #9             ; Copy 10 bytes (without nul)
:       lda     size_output,y
        sta     (ptr2),y
        dey
        bpl     :-

        ; Advance size cache pointer by 10
        adw     mfp_size_cache_ptr, #10

        adw     ptr1, #$04      ; skip the rest of the header, so we can allow up to 255 bytes for the name
        mwa     mfp_fname_cache_ptr, ptr2
        ldy     #$00
        ; write the string location to fname cache
        mway    ptr1, {(ptr2), y}







        ; Advance filename cache pointer by 2
        adw     mfp_fname_cache_ptr, #2

        ; Find length of filename to know how far to advance
        jsr     debug
        setax   ptr1
        jsr     _fc_strlen      ; up to 254 bytes allowed, or $ff for error which we will ignore for now

        ; Total entry length = 8 (header) + filename length + 1 (nul)
        sec                             ; account for nul byte by adding 1 more through C
        adc     mfp_current_entry       ; Add low byte
        sta     mfp_current_entry
        bcc     :+
        inc     mfp_current_entry+1     ; Handle carry to high byte
        clc                             ; need to clear it for next addition

        ; add on the header length as we moved ptr1 on by this
        ; already have value in A
:       adc     #$08
        sta     mfp_current_entry
        bcc     :+
        inc     mfp_current_entry+1     ; Handle carry to high byte

        ; Check if this was the last entry
:       lda     mfp_is_last_group
        bne     done

        inc     mf_entry_index          ; TODO: is this needed?
        jmp     loop_entries

done:   
        rts

.bss
mfp_current_entry:      .res 2
mfp_is_last_group:      .res 1
mfp_e_is_dir:           .res 1

; pointers to current position in cache tables as we build them
mfp_ts_cache_ptr:       .res 2  ; points to next free timestamp slot
mfp_size_cache_ptr:     .res 2  ; points to next free filesize slot
mfp_fname_cache_ptr:    .res 2  ; points to next free filename pointer slot

; this is where the cache copies the current pagegroup data to. just 1 pagegroup (i.e. screen's data for all files and their file sizes etc)
; NOTE: this can't be in BANK as the cache is copying out of cache which is in RAM BANK
; and can't copy into normal memory BANK as they can't be active at same time
mfp_pg_buf:             .res 2048

.segment "BANK"
mfp_timestamp_cache:    .res 16*20      ; "dd/mm/yyyy hh:mm" calculated string without nul
mfp_filesize_cache:     .res 10*20      ; 24 bits max size is "16,777,216", so 10 chars with commas and no nul
mfp_filename_cache:     .res 2*20       ; store the locations of the full names in the page cache
