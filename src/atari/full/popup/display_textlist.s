        .export     display_textlist

        .import     ascii_to_code
        .import     di_current_item
        .import     left_border
        .import     right_border
        .import     return0
        .import     ss_pu_entry
        .import     ss_widget_idx
        .import     ss_width

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

; tmp1,tmp3,tmp4,tmp5,tmp6
; ptr2,ptr4
.proc display_textlist
        mva     {ss_pu_entry + POPUP_NUM_IDX}, tmp4
        mwa     {ss_pu_entry + PopupItemTextList::text}, ptr2
        mva     #$11, tmp1              ; list number as screen code so don't have to convert it
        ; align ptr2 with Y being a 3+x_off based index (it's screen offset after the index is printed plus padding)
        sbw1    ptr2, #$03
        sbw1    ptr2, {ss_pu_entry + PopupItemTextList::x_off}

        ; get the value of the textlist item
        mwa     {ss_pu_entry + POPUP_VAL_IDX}, tmp5
        ldy     #$00
        mva     {(tmp5), y}, tmp5

all_text:
        mva     #$00, tmp3              ; the inverse value to apply to text, this gets ora'd onto char
        sta     tmp6                    ; flag to show we're priting the Arrow for current widget
        jsr     left_border

        ; print any left padding spaces (x_off)
        lda     #FNC_BLANK
        ldx     ss_pu_entry + PopupItemTextList::x_off
        beq     :+
:       sta     (ptr4), y
        iny
        dex
        bne     :-

        ; print digit for current index+1
        mva     tmp1, {(ptr4), y}
        iny

        ; is this the currently highlighted line?
        ; if it is, then set inverse char, and put an arrow at start of the line
        lda     tmp1
        sec
        sbc     #$11            ; the list number makes a convenient loop index, but it starts at #$11
        cmp     tmp5
        bne     :+

        mva     #$80, tmp3              ; current line, so invert text

        ; are we the current widget?
        lda     ss_widget_idx
        cmp     di_current_item
        bne     :+

        inc     tmp6                    ; this is the current, so mark we have to print the closing arrow
        mva     #FNC_L_HL, {(ptr4), y}  ; print the left side indicator arrow
        bne     :++

:       mva     #FNC_BLANK, {(ptr4), y} ; wasn't current line, just print a space
:       iny

        ldx     ss_pu_entry + POPUP_LEN_IDX
:       lda     (ptr2), y               ; fetch a character
        beq     no_trans                ; 0 conveniently maps to screen code for space, and is filler for end of string
        jsr     ascii_to_code
no_trans:
        ora     tmp3                    ; this will invert the char when it's a highlighted line
        sta     (ptr4), y
        iny
        dex
        bne     :-

        lda     tmp6                    ; do we need a closing arrow?
        beq     :+

        ; yes, print it
        mva     #FNC_R_HL, {(ptr4), y}
        iny

:       jsr     right_border

        ; any more lines?
        dec     tmp4
        beq     :+

        ; move to next line, and next string, then reloop
        adw1    ptr4, #SCR_BYTES_W
        adw1    ptr2, {ss_pu_entry + POPUP_LEN_IDX}
        inc     tmp1                    ; next print index
        jmp     all_text
:
        jmp     return0
.endproc
