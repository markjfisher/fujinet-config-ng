        .export     block_line
        .export     copy_entry
        .export     get_pu_loc
        .export     get_edit_loc
        .export     left_border
        .export     pui_is_selectable
        .export     pui_sizes
        .export     right_border
        .export     show_edit_value

        .import     _fc_strlen
        .import     debug
        .import     _pause
        .import     get_scrloc
        .import     put_s_p1p4
        .import     ss_pu_entry
        .import     ss_widget_idx
        .import     ss_width
        .import     ss_y_offset

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
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

.proc right_border
        ; print extra spaces now until width chars printed to remove screen data for shorter lines
        ; this is important as we will shorten the line by 1 to allow the selection indicator char to be placed before border
        lda     #FNC_BLANK
x_space_loop:
        cpy     ss_width
        beq     :+
        bcs     no_x_space      ; finish only when screen index > ss_width

:       sta     (ptr4), y
        iny
        bne     x_space_loop  ; always loop, exit will be when we are > width

no_x_space:
        ; right border
        mva     #FNC_RT_BLK, {(ptr4), y}
        rts
.endproc

; This sets ptr4 to the location of the first byte of the popup on screen.
; assumes ss_width and ss_y_offset are already set correctly for the popup
.proc get_pu_loc
        ; calculate the x-offset to show box. In the inner-box, it's (SCR_WIDTH - width) / 2
        lda     #SCR_WIDTH-3
        sec
        sbc     ss_width
        lsr     a       ; divide by 2
        tax             ; the x offset, in x!

        ldy     #$00
        jsr     get_scrloc          ; saves top left corner into ptr4. careful not to lose ptr4

        ; move location down by ss_y_offset lines
        ldx     ss_y_offset
        beq     :++
:       adw1    ptr4, #SCR_BYTES_W
        dex
        bne     :-
        rts
.endproc

; get location of widget's text field on screen
.proc get_edit_loc
        jsr     get_pu_loc

        ; need to increment it by 2 lines for top bar and heading
        adw1    ptr4, #SCR_BWX2

        ; then 1 line for which widget we currently are
        ldx     ss_widget_idx
        inx
:       adw1    ptr4, #SCR_BYTES_W
        dex
        bne     :-

no_add_x:
        ; now add on the TEXT field length
        setax   ss_pu_entry + PopupItemTextList::text
        jsr     _fc_strlen
        clc
        adc     #$02            ; plus 2 for border and left highlight arrow
        adw1    ptr4, a
        rts
.endproc

.proc show_edit_value
        ; location = ptr4
        ; blank out LEN-1 chars with normal spaces, then print the string. -1 for the nul char which isn't shown
        lda     #FNC_BLANK
        ldx     ss_pu_entry + POPUP_LEN_IDX
        dex
        ldy     #$00
:       sta     (ptr4), y
        iny
        dex
        bne     :-

        ; get the string location into ptr1
        lda     ss_pu_entry + POPUP_VAL_IDX
        sta     ptr1
        lda     ss_pu_entry + POPUP_VAL_IDX+1
        sta     ptr1+1

        ; print it
        jmp     put_s_p1p4
.endproc

.rodata

; sizes, and is_selectable of each PopupItemType
; Types order:
; finish
; space
; textList
; option
; text
; string


pui_sizes:          .byte 1, 1, 8, 9, 4, 7
pui_is_selectable:  .byte 0, 0, 1, 1, 0, 1
