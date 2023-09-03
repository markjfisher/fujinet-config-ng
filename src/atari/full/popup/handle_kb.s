        .export     handle_kb
        .export     type_at_x

        .import     copy_entry
        .import     ss_widget_idx
        .import     ss_items
        .import     ss_num_lr
        .import     ss_other_lr_idx
        .import     ss_num_ud
        .import     ss_other_ud_idx

        .import     _fn_input_ucase
        .import     ss_pu_entry
        .import     di_has_selectable
        .import     pui_sizes

        .import     debug

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

.proc handle_kb

        ; get current popup item into our buffer so we can read values
        ldx     ss_widget_idx
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

        ; do we have any selectables? e.g. info popups have non, so don't want to get stuck in loop here
        lda     di_has_selectable
        bne     :+
        
        ; ignore tab, as we have no selectable widgets. e.g. info
        jmp     start_kb_get

        ; we want to move to next widget that is selectable, with wrap to top if next index = finish
:       ldx     ss_widget_idx
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
        cmp     #PopupItemType::string
        beq     add_1

        stx     ss_widget_idx
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
        bne     :+
        jmp     start_kb_get        ; 0 is also PopupHandleKBEvent::no

:       cmp     #PopupHandleKBEvent::other
        beq     :+

        jmp     do_prev
        ; implicit rts

:       ; a different widget can handle it, we have its index already in ss_other_lr_idx
        ; so swap to the other widget index, load its data, and run the prev on it instead, then restore back to ourselves
        ldx     ss_other_lr_idx
        mwa     #do_prev, ptr3
        jmp     handle_by_other
        ; implicit rts, with result in A

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
        bne     :+
        jmp     start_kb_get

:       cmp     #PopupHandleKBEvent::other
        beq     :+

        jmp     do_next
        ; implicit rts

:       ; a different widget can handle it, we have its index already in ss_other_lr_idx
        ; so swap to the other widget index, load its data, and run the prev on it instead, then restore back to ourselves
        ldx     ss_other_lr_idx
        mwa     #do_next, ptr3
        jmp     handle_by_other
        ; implicit rts

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
        bne     :+
        jmp     start_kb_get

:       cmp     #PopupHandleKBEvent::other
        beq     :+

        jmp     do_prev
        ; implicit rts

:       ; other widget
        ldx     ss_other_ud_idx
        mwa     #do_prev, ptr3
        jmp     handle_by_other
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
        bne     :+
        jmp     start_kb_get

:       cmp     #PopupHandleKBEvent::other
        beq     :+

        jmp     do_next
        ; implicit rts

:       ; other widget
        ldx     ss_other_ud_idx
        mwa     #do_next, ptr3
        jmp     handle_by_other
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

; x = other index to change
; ptr3 = next/prev function to jsr into
handle_by_other:
        lda     ss_widget_idx
        pha
        stx     ss_widget_idx
        jsr     item_x_to_ptr1
        jsr     copy_entry
        jsr     do_jmp

        ; reset back to the current index
        pla
        sta     ss_widget_idx
        tax
        jsr     item_x_to_ptr1
        jsr     copy_entry
        lda     #PopupItemReturn::redisplay
        rts

do_jmp:
        jmp     (ptr3)
        ; the rts in the call will return us back into handle_by_other


do_next_val:
        ; move to next value, rotating if at end
        lda     ss_pu_entry + POPUP_VAL_IDX
        clc
        adc     #$01
        cmp     ss_pu_entry + POPUP_NUM_IDX
        bcc     :+
        lda     #$00

:       rts

do_prev_val:
        ; move to previous value, rotating if at end
        lda     ss_pu_entry + POPUP_VAL_IDX
        sec
        sbc     #$01
        cmp     #$ff
        bne     :+

        ldx     ss_pu_entry + POPUP_NUM_IDX
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
        jsr     debug
        jsr     get_current_item_type
        cmp     #PopupItemType::option
        beq     kb_lr_yes
        
        lda     ss_num_lr
        cmp     #1
        bne     :+

        ; only 1 other can handle this key press, but not current widget
        lda     #PopupHandleKBEvent::other       ; indicate there's another widget that can use this press
        rts 

        ; default to NO, if more types need adding, add them above
:       lda     #PopupHandleKBEvent::no
        rts

kb_lr_yes:
        lda     #PopupHandleKBEvent::self        ; indicate this widget can move L/R
        rts
.endproc

.proc kb_can_do_UD
        jsr     get_current_item_type
        cmp     #PopupItemType::textList
        beq     kb_ud_yes
        
        lda     ss_num_ud
        cmp     #1
        bne     :+

        ; only 1 other can handle this key press, but not current widget
        lda     #PopupHandleKBEvent::other       ; indicate there's another widget that can use this press
        rts 

        ; default to NO, if more types need adding, add them above
:       lda     #PopupHandleKBEvent::no
        rts

kb_ud_yes:
        lda     #PopupHandleKBEvent::self        ; indicate this widget can move L/R
        rts

.endproc

; walk down the PopupItems to the xth, and find its type, return it in A
; trashes tmp1, Y, A, ptr1
.proc type_at_x
        jsr     item_x_to_ptr1
        ldy     #POPUP_TYPE_IDX
        lda     (ptr1), y               ; the type of x'th Item. sets N/Z etc for return too
        rts
.endproc

.proc copy_new_val
        pha     ; push new value so we can retrieve it after getting to correct item
        sta     ss_pu_entry + POPUP_VAL_IDX
        ldx     ss_widget_idx
        jsr     item_x_to_ptr1
        ldy     #POPUP_VAL_IDX
        pla
        sta     (ptr1), y
        rts
.endproc

.proc item_x_to_ptr1
        ; ptr1 will point to start of required PopupItem object
        mwa     ss_items, ptr1
        cpx     #$00
        beq     out

        ; save x
        txa
        pha

        stx     tmp1    ; becomes loop index

        ; move down list until we're at the right one
        ; get size from pui_sizes, x

        ldy     #POPUP_TYPE_IDX
w_loop:
        lda     (ptr1), y
        tax                             ; the type, used as index to...
        lda     pui_sizes, x            ; this widget's type size

        ; add size to ptr1
        adw1    ptr1, a
        dec     tmp1
        bne     w_loop

        ; restore x
        pla
        tax
out:
        rts
.endproc

; sets ptr1 to current popup item
.proc get_current_item_type
        ldx     ss_widget_idx
        jsr     type_at_x
        rts
.endproc
