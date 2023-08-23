        .export     display_option

        .import     fps_pu_entry
        .import     left_border
        .import     ascii_to_code

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_popup_item.inc"

.proc display_option
        mwa     {fps_pu_entry + PopupItem::spc}, ptr3           ; spacings ptr
        mwa     {fps_pu_entry + PopupItem::text}, ptr2          ; texts ptr

        jsr     left_border
        sty     tmp2                    ; screen position index over whole list, left border increments it by 1

        ; now print first string (name) from entry.text.
        ldy     #$00
:       lda     (ptr2), y
        beq     :+                      ; null terminated string
        jsr     ascii_to_code           ; convert to code
        iny
        sty     tmp1                    ; use tmp1 to store current index into string
        ldy     tmp2                    ; get the screen index pointer into y
        sta     (ptr4), y               ; print the character to screen
        iny
        sty     tmp2                    ; move pointer on screen on by 1
        ldy     tmp1                    ; restore character index
        bne     :-                      ; always. the exit it when we hit a 0 char

:       ; add the y+1 index (which points to 0 char of string) onto ptr2 to shift it to next string
        iny
        tya
        clc
        adc     ptr2
        sta     ptr2
        bcc     :+
        inc     ptr2+1

:       ldy     #$00
        sty     tmp1                    ; tmp1 now our main loop variable

widget_loop:
        jsr     print_widget_space
        sty     tmp2                    ; save new position

        ; y is doing double work here, it's the offset of 2 pointers; the current character to display, and the screen offset
        ; print the widget, ptr2 tracks the current widget location
        ldy     #$00
        ldx     fps_pu_entry + PopupItem::len                 ; number of chars to display for each widget
:       lda     (ptr2), y               ; get ascii char
        iny
        sty     tmp3                    ; save y (current character index)
        jsr     ascii_to_code           ; convert to screen code
        ldy     tmp2                    ; restore screen offset
        sta     (ptr4), y               ; print char
        iny
        sty     tmp2
        ldy     tmp3                    ; get index of current char back into y
        dex
        bne     :-                      ; loop over len chars

        ; move ptr2 on by len to next string
        adw1    ptr2, {fps_pu_entry + PopupItem::len}

        ; any more to process?
        inc     tmp1
        lda     tmp1
        tay                             ; the main loop is also index into space array, read at top of loop
        cmp     fps_pu_entry + PopupItem::num
        bne     widget_loop             ; reloop until all widgets done

        ; display final spacing so it overwrites any background text on the screen
        ; tmp1 holds index to last spacings
        ldy     tmp1
        jsr     print_widget_space

        ; right border
        mva     #FNC_RT_BLK, {(ptr4), y}
        rts
.endproc

.proc print_widget_space
        lda     (ptr3), y               ; read number of spaces
        tax        
        ; print this many spaces
        lda     #FNC_BLANK
        ldy     tmp2
:       sta     (ptr4), y
        iny
        dex
        bne     :-
        rts
.endproc