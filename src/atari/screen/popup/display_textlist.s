        .export     display_textlist

        .import     ss_pu_entry
        .import     ss_width
        .import     left_border
        .import     ascii_to_code

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_popup_item.inc"

.proc display_textlist
        mva     {ss_pu_entry + PopupItem::num}, tmp4
        mwa     {ss_pu_entry + PopupItem::text}, ptr2
        mva     #$11, tmp1              ; list number as screen code so don't have to convert it
        ; align ptr2 with Y being a 3 based index (it's screen offset)
        sbw     ptr2, #$03
all_text:
        jsr     left_border

        ; print digit for current index+1
        mva     tmp1, {(ptr4), y}
        iny
        mva     #FNC_BLANK, {(ptr4), y}
        iny

        ldx     ss_pu_entry + PopupItem::len
:       lda     (ptr2), y               ; fetch a character
        beq     no_trans                ; 0 conveniently maps to screen code for space, and is filler for end of string
        jsr     ascii_to_code
no_trans:
        sta     (ptr4), y
        iny
        dex
        bne     :-

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
        adw     ptr4, #40
        adw1    ptr2, {ss_pu_entry + PopupItem::len}
        inc     tmp1                    ; next print index
        bne     all_text                ; always branch
:
        rts
.endproc
