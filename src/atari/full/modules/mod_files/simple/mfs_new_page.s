        .export     mfs_new_page

        .import     _clr_help
        .import     _clr_scr_with_separator
        .import     ellipsize
        .import     _fuji_error
        .import     _fuji_open_directory
        .import     _fuji_set_directory_position
        .import     _free
        .import     _malloc
        .import     _put_help
        .import     _put_s
        .import     _put_status
        .import     _scr_clr_highlight
        .import     copy_path_filter_to_buffer
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     fuji_buffer
        .import     get_to_current_hostslot
        .import     mf_copying
        .import     mf_copying_msg
        .import     mf_dir_pos
        .import     mf_filter
        .import     mf_h1
        .import     mf_host
        .import     mf_path
        .import     mf_s1
        .import     mfs_is_eod
        .import     mh_host_selected
        .import     pusha
        .import     pushax
        .import     return1

        .include    "zp.inc"
        .include    "macros.inc"

.segment "CODE2"

; set up the screen for a new page of files, getting screen ready and buffer with current path, and attempt to open the directory
; ptr1
.proc mfs_new_page
        lda     #$04                    ; print a separator on line 4
        jsr     _clr_scr_with_separator

        jsr     _clr_help
        put_status #0, #mf_s1
        put_help   #0, #mf_h1

        lda     mf_copying
        beq     :+
        put_status #1, #mf_copying_msg          ; need to UNDO this text when we are no longer copying

:       mva     #$00, mfs_is_eod
        jsr     _scr_clr_highlight
        jsr     print_dir_info
        jsr     copy_path_filter_to_buffer

        ; -----------------------------------------------------
        ; open directory
        pusha   mh_host_selected
        setax   #fuji_buffer
        jsr     _fuji_open_directory

        jsr     _fuji_error
        bne     :+

        ; all good, set the dir pos, and return dir pos status
        setax   mf_dir_pos
        jsr     _fuji_set_directory_position
        ; did it fail?
        jmp     _fuji_error

        ; bad times
:       jmp     return1
.endproc


.proc print_dir_info
        ; use 3 lines at the top of screen to display the Host/Filter/Path
        ; titles
        put_s   #0, #0, #mf_host
        put_s   #0, #1, #mf_filter
        put_s   #0, #2, #mf_path

        ; print values
        ; host
        jsr     get_to_current_hostslot         ; sets ptr1 to correct hostslot
        put_s   #5, #0, ptr1

        ; Filter
        lda     fn_dir_filter
        beq     :+
        put_s   #5, #1, #fn_dir_filter

:
        setax   #32             ; max length, including the 0 terminator
        jsr     pusha           ; save as parameter for ellipsize
        jsr     _malloc
        axinto  ptr1            ; save for free
        jsr     pushax          ; dst
        setax   #fn_dir_path    ; src

        jsr     ellipsize

        ; print the ellipsized string
        put_s   #5, #2, ptr1

        ; free the memory we took
        setax   ptr1
        jsr     _free

        rts
.endproc
