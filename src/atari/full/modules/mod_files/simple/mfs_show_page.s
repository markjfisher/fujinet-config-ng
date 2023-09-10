        .export     mfs_show_page

        .import     _fn_io_close_directory
        .import     _fn_io_read_directory
        .import     _fn_io_set_directory_position
        .import     _fc_strlen
        .import     _put_s
        .import     ascii_to_code
        .import     fn_io_buffer
        .import     get_scrloc
        .import     mf_dir_or_file
        .import     mf_dir_pos
        .import     mf_next
        .import     mf_prev
        .import     mfs_entries_cnt
        .import     mfs_entry_index
        .import     mfs_is_eod
        .import     mfs_y_offset
        .import     pusha
        .import     sline2

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"

.proc mfs_show_page
        mva     #$00, mfs_entry_index
l_entries:
        ; clear the dir/file indicator. if it's a dir, the print routine will change the value.
        ldx     mfs_entry_index
        mva     #$00, {mf_dir_or_file, x}

        jsr     read_dir_is_eod
        bne     :+              ; is it a dir?

        ; we are at EOD, so mark it, and skip over any printing
        mva     #$01, mfs_is_eod
        bne     finish_list

:       jsr     print_entry
        inc     mfs_entry_index
        lda     mfs_entry_index
        cmp     #DIR_PG_CNT     ; are there more to do?
        bcc     l_entries

finish_list:
        ; if we have a full page, check if we have any more to come, and set mfs_is_eod. this stops us showing empty pages if there were exactly number of dirs to fill page
        ; Z is set if we have a full page
        bne     :+
        jsr     check_for_next_page

:       mva     mfs_entry_index, mfs_entries_cnt

        ; show the status text arrows if they are relevant
        ; if mf_dir_pos > 0, we can show "prev"
        ; if mfs_is_eod is false we can show "next", this was set if the next page would be empty too
        jsr     clear_status_2
        lda     mf_dir_pos
        beq     :+
        jsr     show_prev

:       lda     mfs_is_eod
        bne     :+
        jsr     show_next

:       jmp     _fn_io_close_directory

.endproc

.proc clear_status_2
        mwa     #sline2, ptr1
        ldy     #SCR_WIDTH-1
        lda     #FNC_FULL
:       sta     (ptr1), y
        dey
        bpl     :-
        rts
.endproc

.proc show_prev
        mwa     #sline2, ptr1
        adw1    ptr1, #$01      ; 1 char into line
        mwa     #mf_prev, ptr2
        jmp     put_mf_s
.endproc

.proc show_next
        mwa     #sline2, ptr1
        adw1    ptr1, #(SCR_WIDTH - 8)          ; string is 8 chars, adjust for end of line
        mwa     #mf_next, ptr2
        jmp     put_mf_s
.endproc

.proc put_mf_s
        ldy     #$00
:       lda     (ptr2), y
        beq     :+              ; string terminator
        jsr     ascii_to_code
        sta     (ptr1), y
        iny
        bne     :-
        rts
.endproc

; reads the next entry and compares to EOD marker
.proc read_dir_is_eod
        pusha   #DIR_MAX_LEN    ; the max length of each line for directory/file names
        pusha   #$00            ; special aux2 param
        setax   #fn_io_buffer
        jsr     _fn_io_read_directory   ; this reads current and moves FN internal directory pointer on 1 position

        ; A/X contain pointer to the data just read
        ; an end of dir is 0x7f, 0x7f
        axinto  ptr1
        ldy     #$01
        lda     (ptr1), y
        cmp     #$7f            ; magic marker
        rts
.endproc

.proc check_for_next_page
        ; set mfs_is_eod if the next page of results only has 7f as first entry
        mwa     mf_dir_pos, ptr1
        adw1    ptr1, #DIR_PG_CNT
        setax   ptr1
        jsr     _fn_io_set_directory_position

        ; read first dir, and check if it's 7f
        jsr     read_dir_is_eod
        bne     :+
        mva     #$01, mfs_is_eod

:       rts
.endproc


.proc print_entry
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
        ldy     mfs_entry_index
        mva     #$01, {mf_dir_or_file, y}

        ; add the screen offset for files starting position into Y
        tya
        clc
        adc     mfs_y_offset
        tay

        jsr     get_scrloc
        ; and print the dir char
        ldy     #$00
        mva     #FNC_DIR_C, {(ptr4), y}

skip_show_dir_char:
        put_s   #$01, mfs_entry_index, ptr1, mfs_y_offset
        rts

.endproc