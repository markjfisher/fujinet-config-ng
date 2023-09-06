        .export     display_textlist

        .import     ss_pu_entry
        .import     ss_width
        .import     left_border
        .import     ascii_to_code
        .import     di_current_item
        .import     ss_widget_idx
        .import     return0

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

.proc display_textlist
        mva     {ss_pu_entry + POPUP_NUM_IDX}, tmp4
        mwa     {ss_pu_entry + PopupItemTextList::text}, ptr2
        mva     #$11, tmp1              ; list number as screen code so don't have to convert it
        ; align ptr2 with Y being a 3 based index (it's screen offset)
        sbw     ptr2, #$03

all_text:
        mva     #$00, tmp3              ; the inverse value to apply to text, this gets ora'd onto char
        sta     dt_display_arrow
        jsr     left_border

        ; print digit for current index+1
        mva     tmp1, {(ptr4), y}
        iny

        ; is this the currently highlighted line?
        ; if it is, then set inverse char, and put an arrow at start of the line
        lda     tmp1
        sec
        sbc     #$11            ; the list number makes a convenient loop index, but it starts at #$11
        cmp     ss_pu_entry + POPUP_VAL_IDX
        bne     :+

        mva     #$80, tmp3              ; current line, so invert text

        ; are we the current widget
        lda     ss_widget_idx
        cmp     di_current_item
        bne     :+

        inc     dt_display_arrow
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

        lda     dt_display_arrow
        cmp     #$01
        bne     :+

        mva     #FNC_R_HL, {(ptr4), y}
        iny

:
        ; print extra spaces now until width chars printed to remove screen data for shorter lines
        ; this is important as we will shorten the line by 1 to allow the selection indicator char to be placed before border
x_space_loop:
        cpy     ss_width
        beq     :+
        bcs     no_x_space      ; finish only when screen index > ss_width

:       lda     #FNC_BLANK
        sta     (ptr4), y
        iny
        bne     x_space_loop  ; always loop, exit will be when we are > width

no_x_space:
        ; right border
        mva     #FNC_RT_BLK, {(ptr4), y}

        ; any more lines?
        dec     tmp4
        beq     :+

        ; move to next line, and next string, then reloop
        adw1    ptr4, #SCR_BYTES_W
        adw1    ptr2, {ss_pu_entry + POPUP_LEN_IDX}
        inc     tmp1                    ; next print index
        jmp     all_text                ; always branch
:
        jmp     return0
.endproc

.bss
dt_display_arrow:       .res 1