        .export     mfp_show_page
        .export     mfp_pg_buf

        ;.export     mfp_start_pg_ptr
        .export     mfp_current_entry
        .export     mfp_e_is_dir

        .export     mfp_timestamp_cache
        .export     mfp_filesize_cache
        .export     mfp_filename_cache
        .export     mf_filename_lengths

        .import     _page_cache_get_pagegroup
        .import     ts_to_datestr
        .import     ts_output
        .import     size_to_str
        .import     size_output

        .import     pushax
        .import     _fc_strlen
        .import     _fc_strncpy
        .import     _get_pagegroup_params
        .import     _put_s
        .import     get_scrloc

        .import     mf_dir_pos
        .import     mf_dir_pg_cnt
        .import     mf_entries_cnt
        .import     mf_entry_index
        .import     mf_selected
        .import     mf_y_offset
        .import     mf_is_eod
        .import     mf_dir_or_file
        .import     clear_status_2
        .import     show_prev
        .import     show_next

        .import     debug

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "page_cache.inc"
        .include    "fn_data.inc"

.segment "CODE2"

mfp_show_page:

        jsr     debug

        ; Path hash already set by mfp_new_page, just setup parameters and get pagegroup
        ; setup the get call's parameters
        mwa     mf_dir_pos, _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position

        ; get the pagegroup (cache lookup already done in mfp_new_page)
        jsr     _page_cache_get_pagegroup

        jsr     debug

        ; now display it, the raw page group data is in mfp_pg_buf
        ; mfp_pg_buf points to cached data, which includes 2 bytes from header for:
        ;  * Byte  0    : Flags
        ;  *              - Bit 7: Last group (1=yes, 0=no)
        ;  *              - Bits 6-0: Reserved
        ;  * Byte  1    : Number of directory entries in this group

        ; followed by
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

        mva     #$00, mf_entry_index

        ; deal with the header bytes
        ; Are we at End of Directory?
        lda     mfp_pg_buf
        and     #$80
        sta     mf_is_eod

        ; How many entries are there in the group?
        mva     mfp_pg_buf+1, mfp_entries_in_group

        ; Show navigation indicators at top of screen
        jsr     clear_status_2
        lda     mf_dir_pos
        beq     :+
        jsr     show_prev
:       lda     mf_is_eod
        bne     :+
        jsr     show_next
:
        ; set mfp_current_entry to start of the page group data
        mwa     #mfp_pg_buf+2, mfp_current_entry

loop_entries:
        lda     mfp_current_entry
        ldx     mfp_current_entry+1
        sta     ptr1
        stx     ptr1+1

        ; Get timestamp string - ptr1 already points to the 4 timestamp bytes
        jsr     ts_to_datestr  ; Result will be in ts_output

        ; Cache the timestamp string using ptr2 and _fc_strncpy
        mwa     mfp_ts_cache_ptr, ptr2
        pushax  ptr2            ; destination
        pushax  #ts_output      ; source
        lda     #17            ; length including null
        jsr     _fc_strncpy
        
        ; Advance timestamp cache pointer by 17 (16 chars + null)
        adw     mfp_ts_cache_ptr, #17

        ; Check if it's a directory (bit 7 of byte 1)
        ldy     #$01
        lda     (ptr1),y
        and     #%10000000     ; Bit 7 = directory flag
        sta     mfp_e_is_dir

        ; Store directory flag in cache
        ldy     mf_entry_index
        sta     mf_dir_or_file,y

        ; Convert size to string (right justified)
        adw     ptr1, #$04
        mwa     ptr1, tmp5
        setax   ptr1
        ldy     #1              ; Right justify
        jsr     size_to_str     ; Result will be in size_output - trashes ptr1-4 via memmove
        mwa     tmp5, ptr1      ; restore ptr1

        ; Cache the size string
        mwa     mfp_size_cache_ptr, ptr2
        pushax  ptr2            ; destination
        pushax  #size_output    ; source
        lda     #11            ; length including null
        jsr     _fc_strncpy

        ; Advance size cache pointer by 11 (10 chars + null)
        adw     mfp_size_cache_ptr, #11

        adw     ptr1, #$04      ; skip the rest of the header, so we can allow up to 255 bytes for the name
        mwa     mfp_fname_cache_ptr, ptr2
        ldy     #$00
        ; write the string location to fname cache
        mway    ptr1, {(ptr2), y}

        ; ------------------------------------------------------------
        ; FILE NAME

        ; is this a directory?
        lda     mfp_e_is_dir
        beq     just_file

        clc
        lda     mf_entry_index
        adc     mf_y_offset
        tay
        ldx     #$00
        jsr     get_scrloc
        ldy     #$00
        mva     #FNC_DIR_C, {(ptr4), y}

just_file:
        ; ellipsize the name in ptr1
        

        put_s   #$01, mf_entry_index, ptr1, mf_y_offset

        ; Advance filename cache pointer by 2
        adw     mfp_fname_cache_ptr, #2

        ; Find length of filename to know how far to advance
        setax   ptr1
        jsr     _fc_strlen      ; up to 254 bytes allowed, or $ff for error which we will ignore for now

        ; Store filename length for animation calculations
        ldy     mf_entry_index
        sta     mf_filename_lengths,y   ; store the actual length

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

:       inc     mf_entry_index
        lda     mf_entry_index

        cmp     mfp_entries_in_group
        beq     done

        jmp     loop_entries

done:
        ; save the entries for the page so the kb handler will let us move around
        mva     mf_entry_index, mf_entries_cnt
        ; print the time and size for first entry
        put_s   #01, #21, #mfp_timestamp_cache

        ; Check if first entry is a directory
        lda     mf_dir_or_file     ; first entry's flag
        beq     show_size

        ; It's a directory, show spaces instead
        put_s   #29, #21, #dir_spaces
        rts

show_size:
        put_s   #27, #21, #mfp_filesize_cache
        rts

.data
dir_spaces:     .byte "          ",0     ; 10 spaces for directory entries

.bss
mfp_current_entry:      .res 2
mfp_e_is_dir:           .res 1
mfp_entries_in_group:   .res 1

; pointers to current position in cache tables as we build them
mfp_ts_cache_ptr:       .res 2  ; points to next free timestamp slot
mfp_size_cache_ptr:     .res 2  ; points to next free filesize slot
mfp_fname_cache_ptr:    .res 2  ; points to next free filename pointer slot

; Filename lengths - 1 byte per entry, actual filename length
mf_filename_lengths:    .res 16 ; Max 16 entries per page

; this is where the cache copies the current pagegroup data to. just 1 pagegroup (i.e. screen's data for all files and their file sizes etc)
; NOTE: this can't be in BANK as the cache is copying out of cache which is in RAM BANK
; and can't copy into normal memory BANK as they can't be active at same time
mfp_pg_buf:             .res 2048

.segment "BANK"
mfp_timestamp_cache:    .res 17*16      ; "dd/mm/yyyy hh:mm" calculated string without nul
mfp_filesize_cache:     .res 11*16      ; 24 bits max size is "16,777,216", so 10 chars with commas and no nul
mfp_filename_cache:     .res 2*16       ; store the locations of the full names in the page cache
