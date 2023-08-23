        .export     handle_kb

        .import     highlight_options
        .import     copy_entry
        .import     fps_widget_idx
        .import     fps_items

        .import     _fn_input_ucase
        .import     fps_pu_entry

        .import     debug

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_popup_item.inc"

.proc handle_kb
        jsr     highlight_options

        ; get current popup item into our buffer so we can read values
        ldx     fps_widget_idx
        jsr     item_x_to_ptr1
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

.proc kb_can_do_LR
        jsr     get_current_item
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
        jsr     get_current_item
        cmp     #PopupItemType::textList
        beq     kb_ud_yes

        ; default to NO, if more types need adding, add them above
        lda     #$00
        rts

kb_ud_yes:
        lda     #$01
        rts
.endproc

; walk down the PopupItems to the xth, and find its type, return it in A
; trashes tmp1, Y, A, ptr1
.proc type_at_x
        jsr     item_x_to_ptr1
        ldy     #PopupItem::type
        lda     (ptr1), y               ; the type of x'th Item. sets N/Z etc for return too
        rts
.endproc

.proc copy_new_val
        ; copy to original and our buffer. TODO: overkill?
        sta     tmp1
        sta     fps_pu_entry + PopupItem::val
        ldx     fps_widget_idx
        jsr     item_x_to_ptr1    ; ptr1 points to given popupitem
        ldy     #PopupItem::val
        lda     tmp1
        sta     (ptr1), y
        rts
.endproc

.proc item_x_to_ptr1
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

; sets ptr1 to current popup item
.proc get_current_item
        ldx     fps_widget_idx
        jsr     type_at_x
        rts
.endproc
