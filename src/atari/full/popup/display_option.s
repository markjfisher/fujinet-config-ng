        .export     display_option
        .export     dopt_reduce_next_space

        .import     ss_pu_entry
        .import     left_border
        .import     ascii_to_code
        .import     ss_widget_idx
        .import     di_current_item
        .import     return0

        .include    "fc_zp.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

.proc display_option
        mwa     {ss_pu_entry + PopupItemOption::spc}, ptr3           ; spacings ptr
        mwa     {ss_pu_entry + PopupItemOption::text}, ptr2          ; texts ptr

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
        adw1    ptr2, a
        ldy     #$00
        sty     tmp1                    ; tmp1 now our main loop variable

        mva     #$00, dopt_reduce_next_space
widget_loop:
        mva     #$00, tmp4              ; the inverse char if option is highlighted
        jsr     print_widget_space
        sty     tmp2                    ; save new position

        ; are we printing the currently selected option?
        lda     ss_pu_entry + POPUP_VAL_IDX
        cmp     tmp1
        bne     :+                      ; no

        ; set inverse on, we are the current 
        mva     #$80, tmp4              ; turn inverting on

        ; but are we the current widget?
        lda     ss_widget_idx
        cmp     di_current_item
        bne     :+

        ; yes, we are both the current selected widget, and the one being displayed
        ; drop back 1 position and print our arrow
        dey
        mva     #FNC_L_HL, {(ptr4), y}
        iny
        inc     dopt_reduce_next_space

        ; y is doing double work here, it's the offset of 2 pointers; the current character to display, and the screen offset
        ; print the widget, ptr2 tracks the current widget location
:       ldy     #$00
        ldx     ss_pu_entry + POPUP_LEN_IDX   ; number of chars to display for each widget
:       lda     (ptr2), y               ; get ascii char
        jsr     ascii_to_code           ; convert to screen code
        ora     tmp4                    ; invert if needed

        iny
        sty     tmp3                    ; save y (current character index)

        ldy     tmp2                    ; restore screen offset
        sta     (ptr4), y               ; print char
        iny
        sty     tmp2
        ldy     tmp3                    ; get index of current char back into y
        dex
        bne     :-                      ; loop over len chars

        
        ; other side of the text print other arrow if we the current widget that's highlighted
        lda     ss_pu_entry + POPUP_VAL_IDX
        cmp     tmp1
        bne     :+              ; no we should not print arrow

        lda     ss_widget_idx
        cmp     di_current_item
        bne     :+              ; no we should not print arrow

        ldy     tmp2
        mva     #FNC_R_HL, {(ptr4), y}
        iny

        ; move ptr2 on by len to next string
:       adw1    ptr2, {ss_pu_entry + POPUP_LEN_IDX}

        ; any more to process?
        inc     tmp1
        lda     tmp1
        tay                             ; the main loop is also index into space array, read at top of loop
        cmp     ss_pu_entry + POPUP_NUM_IDX
        bne     widget_loop             ; reloop until all widgets done

        ; display final spacing so it overwrites any background text on the screen
        ; tmp1 holds index to last spacings
        ldy     tmp1
        jsr     print_widget_space

        ; right border
        mva     #FNC_RT_BLK, {(ptr4), y}
        jmp     return0
.endproc

.proc print_widget_space
        lda     (ptr3), y               ; read number of spaces
        tax
        lda     dopt_reduce_next_space
        cmp     #$00
        beq     :+

        ; the previous widget was highlighted, skip 1 space, else we'll overwrite the arrow
        dex                             ; 1 less space
        inc     tmp2                    ; move screen pointer on 1
        dec     dopt_reduce_next_space  ; reset it

        ; print this many spaces
:       lda     #FNC_BLANK
        ldy     tmp2
:       sta     (ptr4), y
        iny
        dex
        bne     :-

        rts
.endproc

.bss
dopt_reduce_next_space:   .res 1