        .export     mfs_new_page

        .import     _clr_src_with_separator
        .import     _ellipsize
        .import     _fn_io_error
        .import     _fn_io_open_directory
        .import     _fn_io_set_directory_position
        .import     _free
        .import     _malloc
        .import     _put_s
        .import     _scr_clr_highlight
        .import     copy_path_filter_to_buffer
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     fn_io_buffer
        .import     get_to_current_hostslot
        .import     mf_dir_pos
        .import     mf_filter
        .import     mf_host
        .import     mf_path
        .import     mh_host_selected
        .import     pusha
        .import     pushax
        .import     return1

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; set up the screen for a new page of files, getting screen ready and buffer with current path, and attempt to open the directory
.proc mfs_new_page
        lda     #$04                    ; print a separator on line 4
        jsr     _clr_src_with_separator
        jsr     _scr_clr_highlight
        jsr     print_dir_info
        jsr     copy_path_filter_to_buffer

        ; -----------------------------------------------------
        ; open directory
        pusha   mh_host_selected
        setax   #fn_io_buffer
        jsr     _fn_io_open_directory

        jsr     _fn_io_error
        bne     :+

        ; all good, set the dir pos, and return dir pos status
        setax   mf_dir_pos
        jsr     _fn_io_set_directory_position
        ; did it fail?
        jmp     _fn_io_error

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
        lda     #32             ; max length, including the 0 terminator
        jsr     pusha           ; save as parameter for ellipsize
        jsr     _malloc
        axinto  ptr1            ; save for free
        jsr     pushax          ; dst
        setax   #fn_dir_path    ; src
        jsr     _ellipsize

        ; print the ellipsized string
        put_s   #5, #2, ptr1

        ; free the memory we took
        setax   ptr1
        jsr     _free

        rts
.endproc
