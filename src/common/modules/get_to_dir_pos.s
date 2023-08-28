        .export     get_to_dir_pos, path_to_buffer

        .import     _fn_io_open_directory
        .import     _fn_io_set_directory_position
        .import     _fn_strncat
        .import     _fn_strncpy
        .import     _fn_memclr_page
        .import     fn_io_buffer
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     host_selected
        .import     mf_selected
        .import     mf_dir_pos
        .import     pusha, pushax

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

.proc get_to_dir_pos
        jsr     path_to_buffer
        ; open dir for current path, grab the full name of this selected path, and append it to current path string.
        pusha   host_selected
        setax   #fn_io_buffer
        jsr     _fn_io_open_directory

        ; set the directory position to top + highlighted
        lda     mf_selected
        sta     tmp1
        mva     #$00, tmp2
        adw     mf_dir_pos, tmp1, tmp3      ; pretend tmp1 is word value, and save result in tmp3/4

        setax   tmp3                        ; store this in A/X for call
        jmp     _fn_io_set_directory_position
.endproc

; copies the path to buffer, adding on filter if set
.proc path_to_buffer
        setax   #fn_io_buffer
        jsr     _fn_memclr_page

        pushax  #fn_io_buffer
        pushax  #fn_dir_path
        lda     #$e0
        jsr     _fn_strncpy

        lda     fn_dir_filter    ; if filter set, we need to cat it on end
        bne     :+
        rts

:       pushax  #fn_io_buffer
        pushax  #fn_dir_filter
        lda     #$20
        jmp     _fn_strncat

.endproc