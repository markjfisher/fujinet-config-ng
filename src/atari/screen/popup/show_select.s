        .export     _show_select
        .export     fps_pu_entry
        .export     fps_width
        .export     fps_items
        .export     fps_scr_l_strt
        .export     fps_widget_idx

        .import     popax, popa, pusha
        .import     ascii_to_code
        .import     _fn_get_scrloc
        .import     _fn_clr_help
        .import     block_line

        .import     display_items
        .import     handle_kb

        .import     debug

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"
        .include    "fn_popup_item.inc"

; void show_select(uint8 width, void *items, char *msg)
; 
; A generic selection popup window that can display different types of widgets. See
.proc _show_select
        axinto  fps_message             ; the header message to display in popup
        popax   fps_items               ; pointer to the PopupItems to display. contiguous piece of memory that needs breaking up into options and displays
        popa    fps_width               ; the width of the input area excluding the borders which add 1 each side for the border

        jsr     initialise_select       ; show popup header, setup some variables, ptr4 is start of screen

        mva     #$00, fps_widget_idx    ; start on first widget

display_main_loop:
        mwa     fps_items, ptr1         ; set ptr1 to first popup data
        jsr     display_items
        jsr     draw_select_bottom

        ; This is a mini version of gb keyboard handler that understands item types
        jsr     handle_kb

        ; based on return value in A, we will either reloop to display options page again
        ; or exit with values chosen.

        cmp     #PopupItemReturn::redisplay
        bne     exit_show_select

        ; reset the screen pointer to display from the top again minus 1 line, as this is added immediately
        mwa     fps_scr_l_strt, ptr4
        jmp     display_main_loop

exit_show_select:
        rts

.endproc

; draw top part of select with title/help/status, and initialise some values
.proc initialise_select
        jsr     _fn_clr_help
        put_help #2, #mfss_h1
        put_help #3, #mfss_h2

        ; fixing y at 1st line (0) as it has a 4 pixel blank border, so nicely away from top border, but gives max room
        ; calculate the x-offset to show box. In the inner-box, it's (36 - width) / 2
        lda     #35     ; one off for border
        sec
        sbc     fps_width
        lsr     a       ; divide by 2
        tax             ; the x offset, in x!

        ; we'll manipulate screen location directly for speed, so only call scrloc once
        ldy     #$00
        jsr     _fn_get_scrloc          ; saves top left corner into ptr4. careful not to lose ptr4

        ; ----------------------------------------------------------
        ; show top line down
        mva     #FNC_TLW, tmp1
        mva     #FNC_DN_BLK, tmp2
        mva     #FNC_TRW, tmp3
        jsr     block_line

        ; ----------------------------------------------------------
        ; print the popup header message. let the caller worry about centring it with padded spaces
        adw     ptr4, #40
        mwa     fps_message, ptr2
        ; so that we can use same y index for both pointers, need to subtract 1 from ptr2, as y starts at 1
        sbw     ptr2, #$01

        ldy     #$00
        mva     #FNC_FULL, {(ptr4), y}
        iny
        ldx     fps_width
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
        mwa     ptr4, fps_scr_l_strt

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
        adw     ptr4, #40
        mva     #FNC_BLW, tmp1
        mva     #FNC_UP_BLK, tmp2
        mva     #FNC_BRW, tmp3
        jmp     block_line
.endproc

.bss
fps_pu_entry:   .tag PopupItem

fps_message:    .res 2
fps_items:      .res 2
fps_width:      .res 1
fps_widget_idx: .res 1  ; which widget we are currently on (do we just need type?)
fps_scr_l_strt: .res 2

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
