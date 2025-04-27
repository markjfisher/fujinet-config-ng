        .export     mfp_new_page

        .import     _clr_help
        .import     _clr_scr_with_separator
        .import     _fuji_error
        .import     _fuji_open_directory
        .import     _fuji_set_directory_position
        .import     _put_help
        .import     _put_status
        .import     _scr_clr_highlight
        .import     copy_path_filter_to_buffer
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

        .include    "zp.inc"
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

        ; TODO: if non of this changes below, move it into a common file for this and mfs_new_page.s

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
        ; open directory
        pusha   mh_host_selected
        setax   #fuji_buffer
        jsr     _fuji_open_directory

        jsr     _fuji_error
        bne     :+

        ; all good, set the dir pos, and return dir pos status
        ; do we want to keep track of dir_pos in same way as simple?
        setax   mf_dir_pos
        jsr     _fuji_set_directory_position
        ; did it fail?
        jmp     _fuji_error

        ; bad times
:       jmp     return1
.endproc
