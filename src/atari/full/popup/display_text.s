        .export     display_text

        .import     ascii_to_code
        .import     left_border
        .import     right_border
        .import     ss_pu_entry
        .import     ss_width
        .import     return0

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

; print a list of non-editable or selectable strings

; tmp4
; ptr2,ptr4
.proc display_text
        mva     {ss_pu_entry + POPUP_NUM_IDX}, tmp4
        mwa     {ss_pu_entry + PopupItemText::text}, ptr2
        sbw1    ptr2, #$01

all_strings:
        jsr     left_border

:       lda     (ptr2), y       ; fetch a character
        beq     :+
        jsr     ascii_to_code
        sta     (ptr4), y
        iny
        bne     :-              ; always

        ; increment ptr2, the string pointer to next string
:       tya
        adw1    ptr2, a

        jsr     right_border

        ; any more lines?
        dec     tmp4
        beq     :+

        ; move to next line, and string then reloop
        adw1    ptr4, #SCR_BYTES_W
        jmp     all_strings
:
        jmp     return0
.endproc
