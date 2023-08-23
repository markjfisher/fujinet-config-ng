        .export     left_border
        .export     block_line
        .export     copy_entry

        .import     ss_width
        .import     ss_pu_entry

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_popup_item.inc"


; -----------------------------------------------------------
; Helper procedures
; -----------------------------------------------------------


; starts the new line off, setting y, and printing first char.
; assumes ptr4 points to current screen location
.proc left_border
        ldy     #$00
        mva     #FNC_LT_BLK, {(ptr4), y}
        iny
        rts
.endproc

; Prints a block line on screen at current location (assumed ptr4)
; tmp1 = TL char
; tmp2 = middle repeat char
; tmp3 = TR char
.proc block_line
        ldy     #$00
        mva     tmp1, {(ptr4), y}       ; left char
        iny
        ldx     ss_width
        lda     tmp2                    ; middle chars
:       sta     (ptr4), y
        iny
        dex
        bne     :-
        mva     tmp3, {(ptr4), y}       ; right char
        rts
.endproc

; copies current PopupItem into ss_pu_entry, assumes ptr1 points to latest entry, and increments that pointer
.proc copy_entry
        ; read the whole PopupItem entry into ptr2. ptr1 is the current item
        mwa     #ss_pu_entry, ptr2     ; target for copy
        ldy     #$00
:       mva     {(ptr1), y}, {(ptr2), y}
        iny
        cpy     #.sizeof(PopupItem)
        bne     :-
        rts
.endproc
