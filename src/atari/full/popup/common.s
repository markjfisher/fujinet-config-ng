        .export     left_border
        .export     block_line
        .export     copy_entry
        .export     pui_is_selectable
        .export     pui_sizes

        .import     ss_width
        .import     ss_pu_entry

        .include    "fc_zp.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

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

; copies current PopupItem into ss_pu_entry, assumes ptr1 points to latest entry
.proc copy_entry
        ; read the whole PopupItem entry into ptr2. ptr1 is the current item.
        mwa     #ss_pu_entry, ptr2      ; target for copy

        ; get the size of the current item so we know how many bytes to copy
        ; the TYPE is defined to be the first byte, so initialise copy in Y to 0
        ldy     #POPUP_TYPE_IDX
        lda     (ptr1), y
        tax
        lda     pui_sizes, x        ; size
        tax

        ; copy into target from current
:       mva     {(ptr1), y}, {(ptr2), y}
        iny
        dex
        bne     :-

        rts
.endproc

.rodata

; sizes, and is_selectable of each PopupItemType

; Types order:
; finish
; space
; textList
; option
; string


pui_sizes:          .byte 1, 1, 6, 8, 4
pui_is_selectable:  .byte 0, 0, 1, 1, 0
