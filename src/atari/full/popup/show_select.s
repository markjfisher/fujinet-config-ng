        .export     show_select
        .export     ss_args

        .export     ss_pu_entry
        .export     ss_width
        .export     ss_has_sel
        .export     ss_ud_idx
        .export     ss_lr_idx
        .export     ss_str_idx
        .export     ss_scr_l_strt
        .export     ss_widget_idx
        .export     ss_y_offset

        .import     _clr_help
        .import     _fc_strlen
        .import     _pause
        .import     _wait_scan1
        .import     ascii_to_code
        .import     block_line
        .import     debug
        .import     display_items
        .import     get_pu_loc
        .import     handle_kb
        .import     set_next_selectable_widget

        .include    "zp.inc"
        .include    "atari.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

.segment "CODE2"

; A generic selection popup window that can display different types of widgets

; tmp1,tmp2,tmp3
; ptr1,ptr2,ptr4

.proc show_select
        jsr     _wait_scan1             ; only paint when we're at the top of screen so get no flashing
        jsr     initialise_select       ; show popup header, setup some variables, ptr4 is start of screen

display_main_loop:

        jsr     display_items
        jsr     draw_select_bottom

        ; This is a mini version of gb keyboard handler that understands item types
        jsr     handle_kb

        ; based on return value in X, we will either reloop to display options page again (e.g. up/down navigation)
        ; or exit with values chosen (Return or ESC pressed)
        cpx     #PopupItemReturn::redisplay
        bne     exit_select

        ; reset the screen pointer to display from the top again
        mwa     ss_scr_l_strt, ptr4

        jsr     _wait_scan1             ; only paint when we're at the top of screen so get no flashing
        jmp     display_main_loop

exit_select:
        rts

.endproc

.proc show_help
        mwa     ss_args+ShowSelectArgs::help_cb, sh_address

        jmp     $ffff
sh_address = *-2

.endproc

; draw top part of select with title/help/status, and initialise some values
.proc initialise_select
        ; store the popup info in locations we can directly read rather than faffing with Y indexing
        mwa     ss_args+ShowSelectArgs::items, ptr1
        ldy     #$00
        mva     {(ptr1), y}, ss_width
        iny
        mva     {(ptr1), y}, ss_y_offset
        iny
        mva     {(ptr1), y}, ss_has_sel
        iny
        mva     {(ptr1), y}, ss_ud_idx
        iny
        mva     {(ptr1), y}, ss_lr_idx
        iny
        mva     {(ptr1), y}, ss_str_idx
        ; move items pointer forward to entries
        adw1    ss_args+ShowSelectArgs::items, #.sizeof(PopupItemInfo)

        jsr     _clr_help
        jsr     show_help               ; show the custom help messages for this popup
        jsr     get_pu_loc              ; set ptr4 to popup screen location

        ; ----------------------------------------------------------
        ; show top line down
:       mva     #FNC_TLW, tmp1
        mva     #FNC_DN_BLK, tmp2
        mva     #FNC_TRW, tmp3
        jsr     block_line

        ; ----------------------------------------------------------
        ; print the popup header message. centre the text, and invert it. we are given simple ascii string
        adw1    ptr4, #SCR_BYTES_W
        mwa     ss_args+ShowSelectArgs::message, ptr2
        setax   ptr2
        jsr     _fc_strlen
        sta     tmp1            ; save message length
        lda     ss_width
        sec
        sbc     tmp1
        lsr     a               ; (width - msg_len) / 2 = padding
        sta     tmp1
        inc     tmp1            ; add 1 for left border

        ldy     #$00
        lda     #FNC_FULL       ; inverse space screen code
:       sta     (ptr4), y
        iny
        cpy     tmp1
        bne     :-

        ; now print the text. y holds the screen offset from start, subtract it from ptr2 so we can still use y as index
        tya
        sbw1    ptr2, a

:       lda     (ptr2), y
        beq     str_nul
        jsr     ascii_to_code
        ora     #$80            ; inverse text
        sta     (ptr4), y       ; copy letter to screen
        iny
        bne     :-              ; always. the 0 in string will terminate
str_nul:
        ; now print more inverse spaces until we hit the width, and finally add 1 more

        lda     #FNC_FULL
:       sta     (ptr4), y
        iny
        cpy     ss_width
        bcc     :-
        beq     :-

        mva     #FNC_FULL, {(ptr4), y}

        ; ----------------------------------------------------------
        ; Under title
        adw1    ptr4, #SCR_BYTES_W
        mva     #FNC_TL_I, tmp1
        mva     #FNC_UP_BLK, tmp2
        mva     #FNC_TR_I, tmp3
        jsr     block_line

        ; save the current screen location as start of display lines after the title
        adw1    ptr4, #SCR_BYTES_W
        mwa     ptr4, ss_scr_l_strt

        ; get the first selectable widget. Start with $ff, as the set_next will increment to 0 to start
        mva     #$ff, ss_widget_idx
        jsr     set_next_selectable_widget

        rts
.endproc

; bottom of select
.proc draw_select_bottom
        ; close the popup
        ; Pre last line
        mva     #FNC_BL_I, tmp1
        mva     #FNC_DN_BLK, tmp2
        mva     #FNC_BR_I, tmp3
        jsr     block_line

        ; last line
        adw1    ptr4, #SCR_BYTES_W
        mva     #FNC_BLW, tmp1
        mva     #FNC_UP_BLK, tmp2
        mva     #FNC_BRW, tmp3
        jmp     block_line
.endproc


.bss
; this has to be as big as the largest type of popup, as all types will be copied into it for processing.
ss_pu_entry:    .res POPUP_MAX_SZ

ss_width:       .res 1
ss_y_offset:    .res 1
ss_widget_idx:  .res 1
ss_scr_l_strt:  .res 2

ss_has_sel:     .res 1
ss_ud_idx:      .res 1
ss_lr_idx:      .res 1
ss_str_idx:     .res 1

ss_args:        .tag ShowSelectArgs