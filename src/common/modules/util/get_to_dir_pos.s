        .export     get_to_dir_pos, copy_path_filter_to_buffer

        .import     _fn_io_open_directory
        .import     _fn_io_set_directory_position
        .import     _fn_io_error
        .import     _fc_strlcpy
        .import     fn_io_buffer
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     mh_host_selected
        .import     mf_selected
        .import     mf_dir_pos
        .import     pusha, pushax

        .include    "fc_zp.inc"
        .include    "fn_macros.inc"

.proc get_to_dir_pos
        jsr     copy_path_filter_to_buffer
        ; open dir for current path, grab the full name of this selected path, and append it to current path string.
        pusha   mh_host_selected
        setax   #fn_io_buffer
        jsr     _fn_io_open_directory

        ; set the directory position to top + highlighted
        mwa     mf_dir_pos, tmp15
        adw1    tmp15, mf_selected

        ; setax   tmp15  ; a is already tmp15
        ldx     tmp15+1
        jmp     _fn_io_set_directory_position
.endproc

; copies the path to buffer, adding on filter if set
.proc copy_path_filter_to_buffer
        mwa     #fn_io_buffer, tmp15

        ; clear a page of memory
        ldy     #$00
        lda     #$00
:       sta     (tmp15), y
        iny
        bne     :-

        pushax  #fn_io_buffer
        pushax  #fn_dir_path
        lda     #$e0
        jsr     _fc_strlcpy
        sta     tmp4                    ; A/X hold length, will only be low byte

        lda     fn_dir_filter           ; if filter set, we need to cat it on end
        bne     :+
        rts

        ; we have to put the filter 1 byte after the null of the path, not append it
        ; as there has to be a 0 null between path and filter.
:       inc     tmp4
        mwa     #fn_io_buffer, ptr3
        adw1    ptr3, tmp4

        ; now copy filter to ptr3 until we've copied the zero null terminator
        mwa     #fn_dir_filter, ptr4
        ldy     #$00
:       mva     {(ptr4), y}, {(ptr3), y}
        iny
        cmp     #$00    ; have we done the null byte, 0 yet?
        bne     :-      ; no

        rts
.endproc