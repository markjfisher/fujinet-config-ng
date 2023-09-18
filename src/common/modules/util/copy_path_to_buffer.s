        .export     copy_path_to_buffer
        .export     copy_path_filter_to_buffer

        .import     _fc_strlcpy
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     fn_io_buffer
        .import     pushax

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"

; just the path to the buffer
.proc copy_path_to_buffer
        mwa     #fn_io_buffer, tmp9

        ; clear a page of memory
        ldy     #$00
        lda     #$00
:       sta     (tmp9), y
        iny
        bne     :-

        pushax  #fn_io_buffer
        pushax  #fn_dir_path
        lda     #$e0
        jsr     _fc_strlcpy
        sta     tmp4                    ; A/X hold length, will only be low byte
        rts
.endproc

; copies the path to buffer, adding on filter if set
.proc copy_path_filter_to_buffer
        jsr     copy_path_to_buffer

        ; now append the filter if set
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