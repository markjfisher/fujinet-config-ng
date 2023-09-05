        .export     mfs_show_page

        .import     _fn_io_close_directory
        .import     _fn_io_read_directory
        .import     _fn_strlen
        .import     _put_s
        .import     fn_io_buffer
        .import     get_scrloc
        .import     mf_dir_or_file
        .import     mfs_entries_cnt
        .import     mfs_entry_index
        .import     mfs_y_offset
        .import     pusha

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

        pusha   #DIR_MAX_LEN    ; the max length of each line for directory/file names
        pusha   #$00            ; special aux2 param
        setax   #fn_io_buffer
        jsr     _fn_io_read_directory

        ; A/X contain pointer to the data just read (which is also just fn_io_buffer)
        ; an end of dir is 0x7f, 0x7f
        axinto  ptr1
        ldy     #$01
        lda     (ptr1), y

        cmp     #$7f            ; magic marker
        beq     finish_list

        jsr     print_entry

        inc     mfs_entry_index
        lda     mfs_entry_index
        cmp     #DIR_PG_CNT     ; are there more to do?
        bcc     l_entries

finish_list:
        ; make mfs_entries_cnt be 0 based
        ; save the number we showed, so we know if we can move highlight down, and if we are at EOD yet
        ; (if it's equal to DIR_PG_CNT, we still have more pages to show)
        ; TODO WHAT IF IT'S LAST? TRY 16 EXACT
        mva     mfs_entry_index, mfs_entries_cnt
        jmp     _fn_io_close_directory

.endproc


.proc print_entry
        ; is this a dir? last char of name is '/' - ASSUMPTION - string never 0 length
        setax   ptr1
        jsr     _fn_strlen
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