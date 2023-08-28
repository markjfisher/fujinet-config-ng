        .export     _show_select
        .export     ss_pu_entry
        .export     ss_width
        .export     ss_items
        .export     ss_scr_l_strt
        .export     ss_widget_idx

        .export     ss_num_lr
        .export     ss_other_lr_idx
        .export     ss_num_ud
        .export     ss_other_ud_idx

        .import     popax, popa, pusha
        .import     ascii_to_code
        .import     fn_get_scrloc
        .import     _fn_clr_help
        .import     _fn_put_help
        .import     block_line

        .import     display_items
        .import     handle_kb
        .import     _wait_scan1

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

; void show_select(uint8_t width, void *items, char *msg)
; 
; A generic selection popup window that can display different types of widgets
;
; ptr4 is set to the screen location needed at any one time in the showing of the widget
; be careful not to trash it.
.proc _show_select
        axinto  ss_message             ; the header message to display in popup
        popax   ss_items               ; pointer to the PopupItems to display. contiguous piece of memory that needs breaking up into options and displays
        popa    ss_width               ; the width of the input area excluding the borders which add 1 each side for the border

        jsr     _wait_scan1             ; only paint when we're at the top of screen so get no flashing
        jsr     initialise_select       ; show popup header, setup some variables, ptr4 is start of screen

display_main_loop:

        jsr     display_items
        jsr     draw_select_bottom

        ; This is a mini version of gb keyboard handler that understands item types
        jsr     handle_kb

        ; based on return value in A, we will either reloop to display options page again (e.g. up/down navigation)
        ; or exit with values chosen (Return or ESC pressed)

        cmp     #PopupItemReturn::redisplay
        bne     exit_select

        ; reset the screen pointer to display from the top again
        mwa     ss_scr_l_strt, ptr4

        jsr     _wait_scan1             ; only paint when we're at the top of screen so get no flashing
        jmp     display_main_loop

exit_select:
        rts

.endproc

; draw top part of select with title/help/status, and initialise some values
.proc initialise_select
        ; initialise some variables
        mva     #$00, ss_widget_idx     ; start on first widget
        sta     ss_num_lr               ; track number of L/R widgets for keyboard shortcuts
        sta     ss_num_ud               ; track number of U/D widgets for keyboard shortcuts

        ; clear screen and print help texts
        jsr     _fn_clr_help
        put_help #2, #mfss_h1
        put_help #3, #mfss_h2

        ; calculate the x-offset to show box. In the inner-box, it's (36 - width) / 2
        lda     #35     ; one off for border
        sec
        sbc     ss_width
        lsr     a       ; divide by 2
        tax             ; the x offset, in x!

        ; we'll manipulate screen location directly for speed, so only call scrloc once
        ldy     #$00
        jsr     fn_get_scrloc          ; saves top left corner into ptr4. careful not to lose ptr4

        ; ----------------------------------------------------------
        ; show top line down
        mva     #FNC_TLW, tmp1
        mva     #FNC_DN_BLK, tmp2
        mva     #FNC_TRW, tmp3
        jsr     block_line

        ; ----------------------------------------------------------
        ; print the popup header message. let the caller worry about centring it with padded spaces
        adw     ptr4, #40
        mwa     ss_message, ptr2
        ; so that we can use same y index for both pointers, need to subtract 1 from ptr2, as y starts at 1
        sbw     ptr2, #$01

        ldy     #$00
        mva     #FNC_FULL, {(ptr4), y}
        iny
        ldx     ss_width
:       lda     (ptr2), y
        jsr     ascii_to_code
        sta     (ptr4), y               ; copy letter to screen
        iny
        dex
        bne     :-
        mva     #FNC_FULL, {(ptr4), y}

        ; ----------------------------------------------------------
        ; Under title
        adw     ptr4, #40
        mva     #FNC_TL_I, tmp1
        mva     #FNC_UP_BLK, tmp2
        mva     #FNC_TR_I, tmp3
        jsr     block_line

        ; save the current screen location as start of display lines after the title
        adw     ptr4, #40
        mwa     ptr4, ss_scr_l_strt

        ; get the counts of the L/R and U/D widgets in the popup items
        jmp     count_widget_types

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
        adw     ptr4, #40
        mva     #FNC_BLW, tmp1
        mva     #FNC_UP_BLK, tmp2
        mva     #FNC_BRW, tmp3
        jmp     block_line
.endproc

; Count the number of LR or UD widgets for keyboard handling
.proc count_widget_types
        mwa     ss_items, ptr1          ; reset ptr1
        ldy     #PopupItem::type
        ldx     #$00
loop:
        lda     (ptr1), y
        
        cmp     #PopupItemType::textList
        beq     inc_ud
        cmp     #PopupItemType::option
        beq     inc_lr
        cmp     #PopupItemType::finish
        beq     out

next:   adw     ptr1, #.sizeof(PopupItem)
        inx
        jmp     loop

inc_ud:
        stx     ss_other_ud_idx
        inc     ss_num_ud
        bne     next

inc_lr:
        stx     ss_other_lr_idx
        inc     ss_num_lr
        bne     next

out:
        rts
.endproc


.bss
ss_pu_entry:    .tag PopupItem

ss_message:     .res 2
ss_items:       .res 2
ss_width:       .res 1
ss_widget_idx:  .res 1
ss_scr_l_strt:  .res 2

; these help track the number of widgets that can handle L/R or U/D key presses for streamlined user experience
; when pressing those keys.
ss_num_lr:       .res 1
ss_other_lr_idx: .res 1
ss_num_ud:       .res 1
ss_other_ud_idx: .res 1

.segment "SCREEN"

mfss_h1:
                NORMAL_CHARMAP
                .byte $81, $1c, $1d, $82        ; endL up down endR
                INVERT_ATASCII
                .byte "Move "
                NORMAL_CHARMAP
                .byte $81, "TAB", $82
                INVERT_ATASCII
                .byte "Next Widget", 0

mfss_h2:
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "Complete"
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0
