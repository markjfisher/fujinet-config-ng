        .export     get_to_dir_pos, copy_path_filter_to_buffer

        .import     _fn_io_open_directory
        .import     _fn_io_set_directory_position
        .import     _fn_memclr_page
        .import     _fn_io_error
        .import     _fn_strlcpy
        .import     fn_io_buffer
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     host_selected
        .import     mf_selected
        .import     mf_dir_pos
        .import     pusha, pushax

        .import     debug

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

.proc get_to_dir_pos
        jsr     copy_path_filter_to_buffer
        ; open dir for current path, grab the full name of this selected path, and append it to current path string.
        pusha   host_selected
        setax   #fn_io_buffer
        jsr     _fn_io_open_directory

        ; set the directory position to top + highlighted
        mwa     mf_dir_pos, ptr1
        adw1    ptr1, mf_selected

        ; setax   ptr1  ; a is already ptr1
        ldx     ptr1+1
        jmp     _fn_io_set_directory_position
.endproc

; copies the path to buffer, adding on filter if set
.proc copy_path_filter_to_buffer
        setax   #fn_io_buffer
        jsr     _fn_memclr_page         ; relies on our buffer being 256 bytes

        pushax  #fn_io_buffer
        pushax  #fn_dir_path
        lda     #$e0
        jsr     _fn_strlcpy
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