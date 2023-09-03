        .export     display_string

        .import     ascii_to_code
        .import     left_border
        .import     ss_pu_entry
        .import     ss_width
        .import     return0

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

; print a list of non-editable or selectable strings
.proc display_string
        mva     {ss_pu_entry + POPUP_NUM_IDX}, tmp4
        mwa     {ss_pu_entry + PopupItemString::text}, ptr2
        sbw1    ptr2, #$01

all_strings:
        jsr     left_border

:
        lda     (ptr2), y       ; fetch a character
        beq     :+
        jsr     ascii_to_code
        sta     (ptr4), y
        iny
        bne     :-              ; always

        ; increment ptr2, the string pointer to next string
:
        tya
        adw1    ptr2, a

        ; fill up to the end of line
x_space_loop:
        cpy     ss_width
        beq     :+
        bcs     no_x_space

:       lda     #FNC_BLANK
        sta     (ptr4), y
        iny
        bne     x_space_loop

no_x_space:
        mva     #FNC_RT_BLK, {(ptr4), y}

        ; any more lines?
        dec     tmp4
        beq     :+

        ; move to next line, and string then reloop
        adw     ptr4, #40
        jmp     all_strings                ; always branch
:
        jmp     return0
.endproc
