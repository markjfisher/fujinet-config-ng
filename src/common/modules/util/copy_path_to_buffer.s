        .export     copy_path_to_buffer
        .export     copy_path_filter_to_buffer

        .import     _fc_strlcpy
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     fuji_buffer

        .import     _bzero
        .import     pushax
        .import     return1

        .include    "zp.inc"
        .include    "macros.inc"

; tmp4,tmp9
; ptr3,ptr4

; just the path to the buffer
.proc copy_path_to_buffer
;         mwa     #fuji_buffer, tmp9

;         ; clear a page of memory
;         ldy     #$00
;         lda     #$00
; :       sta     (tmp9), y
;         iny
;         bne     :-

        pushax  #fuji_buffer
        setax   #$100
        jsr     _bzero

        pushax  #fuji_buffer
        pushax  #fn_dir_path
        lda     #$e0
        jsr     _fc_strlcpy
        sta     tmp4                    ; A/X hold length, will only be low byte
        rts
.endproc

; copies the path to buffer, adding on filter if set
; returns 0 (Z set) if there's no filter added, 1 if there is a filter added, allowing callers to know to skip the null if they need to (page cache)
.proc copy_path_filter_to_buffer
        jsr     copy_path_to_buffer

        ; now append the filter if set
        lda     fn_dir_filter           ; if filter set, we need to cat it on end
        bne     :+
        ; A = 0, Z = 1, tells caller there was no filter
        rts

        ; we have to put the filter 1 byte after the null of the path, not append it
        ; as there has to be a 0 null between path and filter.
:       inc     tmp4            ; set in copy_path_to_buffer
        mwa     #fuji_buffer, ptr3
        adw1    ptr3, tmp4

        ; now copy filter to ptr3 until we've copied the zero null terminator
        mwa     #fn_dir_filter, ptr4
        ldy     #$00
:       mva     {(ptr4), y}, {(ptr3), y}
        iny
        cmp     #$00    ; have we done the null byte, 0 yet?
        bne     :-      ; no

        ; let the caller know there was a buffer added
        jsr     return1
.endproc