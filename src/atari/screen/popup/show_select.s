        .export     _show_select
        .export     fps_pu_entry
        .export     fps_width

        .import     popax, popa, pusha
        .import     ascii_to_code
        .import     _fn_get_scrloc
        .import     _fn_input_ucase
        .import     _fn_strlen
        .import     _fn_clr_help
        .import     _fn_put_help
        .import     copy_entry
        .import     block_line

        .import     display_items

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

; -----------------------------------------------------------
; show_select keyboard handler
; -----------------------------------------------------------
        ; This is a mini version of gb keyboard handler that understands item types
        jsr     handle_kb

        ; based on return value in A, we will either reloop to display options page again
        ; or exit with values chosen.

        cmp     #PopupItemReturn::redisplay
        bne     exit_show_select

        ; reset the screen pointer to display from the top again minus 1 line, as this is added immediately
        mwa     fps_scr_l_strt, ptr4
        sbw     ptr4, #40
        jmp     display_main_loop

exit_show_select:
        rts

initialise_select:
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
        mwa     ptr4, fps_scr_l_strt
        adw     fps_scr_l_strt, #40    ; it needs moving to next line, as we are on the "under title" line

        rts

draw_select_bottom:
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


; ==============================================================================
; handle_kb
; ==============================================================================

; allows new scoping, but also access to everything in this file
.proc handle_kb
        jsr     highlight_options

        ; get current popup item into our buffer so we can read values
        ldx     fps_widget_idx
        jsr     ptr1_popup_x
        jsr     copy_entry

start_kb_get:
        jsr     _fn_input_ucase
        cmp     #$00
        beq     start_kb_get

; --------------------------------------------------------------------
; main popup select  kb switch
; --------------------------------------------------------------------

; valid keys are up/down/enter/esc/tab/left/right

; - enter selects current options that are highlighted
; - ESC always exits with no changes to be made (return '1' in A).
; - tab moves between widgets
; - in an option widget, L/R are allowed, not up/down
; - in a list, U/D allowed, L/R not
; - HOWEVER, if there's only 1 widget of each type, then allow either movement type
;   to remove the need to press tab.
; - Space widget should be skipped

; Highlighting:
; - options text is inverted with 2 chars around current option
; - list entry is inverted for entire line
;
; Current selected is stored in popupItem.val for each item, 0 index

; --------------------------------------------------------------------
; TAB - switch widget
; --------------------------------------------------------------------
        cmp     #FNK_TAB
        bne     not_tab

        ; we want to move to next non-space, with wrap to top if next index = finish
        ldx     fps_widget_idx
add_1:
        inx
get_type:
        jsr     type_at_x               ; get type of x'th popup Item
        cmp     #PopupItemType::finish
        bne     :+
        ldx     #$00
        beq     get_type
:       cmp     #PopupItemType::space
        beq     add_1

        stx     fps_widget_idx
        ldx     #$00
        lda     #PopupItemReturn::redisplay
        rts

not_tab:
; --------------------------------------------------------------------
; LEFT - option only
; --------------------------------------------------------------------
        cmp     #FNK_LEFT
        beq     is_left
        cmp     #FNK_LEFT2
        bne     not_left

is_left:
        jsr     kb_can_do_LR
        beq     start_kb_get

        jsr     do_prev_val
        jsr     copy_new_val
        ldx     #$00
        lda     #PopupItemReturn::redisplay
        rts

not_left:
; --------------------------------------------------------------------
; RIGHT - option only
; --------------------------------------------------------------------
        cmp     #FNK_RIGHT
        beq     is_right
        cmp     #FNK_RIGHT2
        bne     not_right

is_right:
        jsr     kb_can_do_LR
        beq     start_kb_get

        jsr     do_next_val
        jsr     copy_new_val
        ldx     #$00
        lda     #PopupItemReturn::redisplay
        rts

not_right:
; --------------------------------------------------------------------
; UP - list only
; --------------------------------------------------------------------
        cmp     #FNK_UP
        beq     is_up
        cmp     #FNK_UP2
        bne     not_up
is_up:
        jsr     kb_can_do_UD
        beq     start_kb_get
        jmp     do_prev
        ; implicit rts

not_up:
; --------------------------------------------------------------------
; DOWN - list only
; --------------------------------------------------------------------
        cmp     #FNK_DOWN
        beq     is_down
        cmp     #FNK_DOWN2
        bne     not_down
is_down:
        jsr     kb_can_do_UD
        beq     start_kb_get
        jmp     do_next
        ; implicit rts

not_down:
; --------------------------------------------------------------------
; ESC - leave processing
; --------------------------------------------------------------------
        cmp     #FNK_ESC
        bne     not_esc

        ; exit with escape code, caller will act on it.
        ldx     #$00
        lda     #PopupItemReturn::escape
        rts
not_esc:
; --------------------------------------------------------------------
; ENTER - finish interaction
; --------------------------------------------------------------------
        cmp     #FNK_ENTER
        bne     not_enter

        ; simple, just exit with complete code, the caller will read out any data as needed
        ldx     #$00
        lda     #PopupItemReturn::complete
        rts

not_enter:

; --------------------------------------------------------------------
; end of keyboard switch, reloop until ESC or Enter is hit
; --------------------------------------------------------------------

        jmp     start_kb_get


do_next_val:
        ; move to next value, rotating if at end
        lda     fps_pu_entry + PopupItem::val
        clc
        adc     #$01
        cmp     fps_pu_entry + PopupItem::num
        bcc     :+
        lda     #$00

:       rts

do_prev_val:
        ; move to previous value, rotating if at end
        lda     fps_pu_entry + PopupItem::val
        sec
        sbc     #$01
        cmp     #$ff
        bne     :+

        ldx     fps_pu_entry + PopupItem::num
        dex
        txa

:       rts

do_prev:
        jsr     do_prev_val
        jmp     copy_ret

do_next:
        jsr     do_next_val
        jmp     copy_ret

copy_ret:
        jsr     copy_new_val
        ldx     #$00
        lda     #PopupItemReturn::redisplay
        rts

.endproc

.proc copy_new_val
        ; copy to original and our buffer. TODO: overkill?
        sta     tmp1
        sta     fps_pu_entry + PopupItem::val
        ldx     fps_widget_idx
        jsr     ptr1_popup_x    ; ptr1 points to given popupitem
        ldy     #PopupItem::val
        lda     tmp1
        sta     (ptr1), y
        rts
.endproc

.proc highlight_options
        ; take the current selection, and widget index, and highlight the right things

        jsr     debug
        ; highlight the current selection on each item
        mwa     fps_items, ptr1                 ; first entry
        mwa     fps_scr_l_strt, ptr3            ; ptr3 is our moving screen location per widget
        mva     #$00, tmp3                      ; track which widget we're on, and superhighlight it if it matches current

; loop around all the entries until we hit exit
all_entries:
        jsr     copy_entry        ; expects ptr1 to point to a PopupItem
        lda     fps_pu_entry + PopupItem::type
        cmp     #PopupItemType::finish
        bne     not_finish
        jmp     end_hl

not_finish:
; ---------------------------------------------------------------------------
; textList
; ---------------------------------------------------------------------------
        cmp     #PopupItemType::textList
        bne     not_text_list

        ; get current selection within the texts to display
        lda     fps_pu_entry + PopupItem::val
        sta     tmp1

        ; loop through the entries until we are on current selection
        ldx     #$00
:       cpx     tmp1
        beq     found_line
        adw     ptr3, #40
        inx
        bne     :-

found_line:
        ; highlight the text from ptr3+3 to ptr3+entry::len
        ldy     #$03
        ldx     fps_pu_entry + PopupItem::len
:       lda     (ptr3), y
        ora     #$80
        sta     (ptr3), y
        iny
        dex
        bne     :-

        ; is this current list selection?
        lda     fps_widget_idx
        cmp     tmp3
        bne     :+

        ; yes, super highlight the entry at ptr3+2, and ptr3+len+2 as we are currently editing this list item
        ldy     #$02
        lda     #FNC_L_HL
        sta     (ptr3), y

        lda     fps_pu_entry + PopupItem::len
        clc
        adc     #$03            ; adjust for the list count spacing
        tay
        lda     #FNC_R_HL
        sta     (ptr3), y


        ; need to increment ptr3 over rest of lines so it starts at the next widget
        ; i.e. (num - tmp1) * 40
:       lda     fps_pu_entry + PopupItem::num
        sec
        sbc     tmp1
        tax
:       adw     ptr3, #40
        dex
        bne     :-

        jmp     next_entry

not_text_list:
; ---------------------------------------------------------------------------
; option
; ---------------------------------------------------------------------------
        cmp     #PopupItemType::option
        bne     not_option

        ; get string length of name into tmp2, this will be our offset to the option to highlight
        setax   fps_pu_entry + PopupItem::text
        jsr     _fn_strlen
        sta     tmp2
        inc     tmp2    ; add 1 for border

        lda     fps_pu_entry + PopupItem::val
        sta     tmp1

        ; add the spacer offsets up to chosen item into tmp2
        ldy     #$00
        mwa     {fps_pu_entry + PopupItem::spc}, ptr2        ; begining of offsets
:       lda     (ptr2), y
        clc
        adc     tmp2
        sta     tmp2
        iny
        cpy     tmp1
        bcc     :-
        beq     :-

        ; add lengths of previous option texts until hit current selected option
        ldx     #$00
:       cpx     tmp1
        beq     found_option
        lda     tmp2
        clc
        adc     fps_pu_entry + PopupItem::len
        sta     tmp2
        inx
        bne     :-

found_option:
        ldy     tmp2
        ldx     fps_pu_entry + PopupItem::len
:       lda     (ptr3), y
        ora     #$80
        sta     (ptr3), y
        iny
        dex
        bne     :-

        ; is this current list selection?
        lda     fps_widget_idx
        cmp     tmp3
        bne     :+

        ; yes, put HL chars around the field
        ldy     tmp2
        dey
        lda     #FNC_L_HL
        sta     (ptr3), y
        tya
        clc
        adc     fps_pu_entry + PopupItem::len
        tay
        iny
        lda     #FNC_R_HL
        sta     (ptr3), y


        ; add 40 to ptr3 to point to next line
:       adw     ptr3, #40

        jmp     next_entry

not_option:
; ---------------------------------------------------------------------------
; space
; ---------------------------------------------------------------------------
        cmp     #PopupItemType::space
        bne     not_space
        ; add a line to the screen pointer
        adw     ptr3, #40
        ; drop through

not_space:

next_entry:
        inc     tmp3            ; increment which widget the next one will be
        adw     ptr1, #.sizeof(PopupItem)
        jmp     all_entries

end_hl:
        rts
.endproc

; walk down the PopupItems to the xth, and find its type, return it in A
; trashes tmp1, Y, A, ptr1
.proc type_at_x
        jsr     ptr1_popup_x
        ldy     #PopupItem::type
        lda     (ptr1), y               ; the type of x'th. sets N/Z etc for return too
        rts
.endproc

.proc ptr1_popup_x
        ; ptr1 will point to start of required PopupItem object
        mwa     fps_items, ptr1
        ; save x
        txa
        pha
        cpx     #$00
        beq     :++

        ; move down list until we're at the right one
:       adw     ptr1, #.sizeof(PopupItem)
        dex
        bne     :-

:
        pla
        tax
        rts
.endproc

.proc kb_can_do_LR
        ldx     fps_widget_idx
        jsr     type_at_x
        cmp     #PopupItemType::option
        beq     kb_lr_yes

        ; default to NO, if more types need adding, add them above
        lda     #$00
        rts

kb_lr_yes:
        lda     #$01
        rts
.endproc

.proc kb_can_do_UD
        ldx     fps_widget_idx
        jsr     type_at_x
        cmp     #PopupItemType::textList
        beq     kb_ud_yes

        ; default to NO, if more types need adding, add them above
        lda     #$00
        rts

kb_ud_yes:
        lda     #$01
        rts
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
