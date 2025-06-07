        .export     mfs_show_page

        .import     _fuji_close_directory
        .import     _fuji_read_directory
        .import     _fuji_set_directory_position
        .import     _fc_strlen
        .import     _put_s
        .import     ascii_to_code
        .import     fuji_buffer
        .import     get_scrloc
        .import     mf_dir_or_file
        .import     mf_dir_pg_cnt
        .import     mf_dir_pos
        .import     mf_entries_cnt
        .import     mf_entry_index
        .import     mf_is_eod
        .import     mf_y_offset
        .import     pusha
        .import     clear_status_2
        .import     show_prev
        .import     show_next

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "fn_data.inc"

.segment "CODE2"

; ptr1,ptr2,ptr4
mfs_show_page:
        mva     #$00, mf_entry_index
l_entries:
        ; clear the dir/file indicator. if it's a dir, the print routine will change the value.
        ldx     mf_entry_index
        mva     #$00, {mf_dir_or_file, x}

        jsr     read_dir_is_eod
        bne     :+              ; is it last entry of whole directory path?

        ; we are at EOD, so mark it, and skip over any printing
        mva     #$01, mf_is_eod
        bne     skip_check_for_next_page

:       jsr     print_entry
        inc     mf_entry_index
        lda     mf_entry_index
        cmp     mf_dir_pg_cnt   ; are there more to do?
        bcc     l_entries

        ; if we ended on a full page, check if we have any more to come, and set mf_is_eod.
        ; this stops us showing empty pages if there were exactly number of dirs to fill page

        ; set mf_is_eod if the next page of results only has 7f as first entry
        mwa     mf_dir_pos, ptr1
        adw1    ptr1, mf_dir_pg_cnt
        setax   ptr1
        jsr     _fuji_set_directory_position

        ; read first dir, and check if it's 7f, Z=1 if it is EOD
        jsr     read_dir_is_eod
        bne     skip_check_for_next_page
        mva     #$01, mf_is_eod

skip_check_for_next_page:
        mva     mf_entry_index, mf_entries_cnt

        ; show the status text arrows if they are relevant
        ; if mf_dir_pos > 0, we can show "prev"
        ; if mf_is_eod is false we can show "next", this was set if the next page would be empty too
        jsr     clear_status_2
        lda     mf_dir_pos
        beq     :+
        jsr     show_prev

:       lda     mf_is_eod
        bne     :+
        jsr     show_next

:       jmp     _fuji_close_directory

; reads the next entry and compares to EOD marker
read_dir_is_eod:
        pusha   #DIR_MAX_LEN    ; the max length of each line for directory/file names
        pusha   #$00            ; special aux2 param
        setax   #fuji_buffer
        jsr     _fuji_read_directory   ; this reads current and moves FN internal directory pointer on 1 position

        ; fuji_buffer contains the results
        ; an end of dir is 0x7f, 0x7f
        ; IMPORTANT: This sets ptr1 to the buffer, and is used in other functions in here, so is a SIDE EFFECT of this function
        mwa     #fuji_buffer, ptr1
        ldy     #$01
        lda     (ptr1), y
        cmp     #$7f            ; magic marker
        rts


; Assumption:
;  ptr1 is set to #fuji_buffer
print_entry:
        ; is this a dir? last char of name is '/' - ASSUMPTION - string never 0 length
        setax   ptr1
        jsr     _fc_strlen
        tay
        dey
        lda     (ptr1), y       ; the last character of string
        cmp     #'/'
        bne     skip_show_dir_char

        ; unset the final '/' in string, we don't need to display it as we have a dir char
        mva     #$00, {(ptr1), y}
        tax                         ; x coordinate = 0

        ; save the fact this is a dir so that when it's chosen we traverse it rather than choose it for a device slot
        ldy     mf_entry_index
        mva     #$01, {mf_dir_or_file, y}

        ; add the screen offset for files starting position into Y
        tya
        clc
        adc     mf_y_offset
        tay

        jsr     get_scrloc
        ; and print the dir char
        ldy     #$00
        mva     #FNC_DIR_C, {(ptr4), y}

skip_show_dir_char:
        put_s   #$01, mf_entry_index, ptr1, mf_y_offset
        rts
