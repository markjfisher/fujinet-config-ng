        .export     handle_kb
        .export     pu_kb_cb
        .export     pu_null_cb
        .export     do_edit

        .import     _edit_string
        .import     _es_params
        .import     _fc_strlen
        .import     _kb_get_c_ucase
        .import     _create_new_disk
        .import     copy_entry
        .import     debug
        .import     get_edit_loc
        .import     item_x_to_ptr1
        .import     load_widget_x
        .import     m_l1
        .import     pui_sizes
        .import     pusha
        .import     pushax
        .import     set_next_selectable_widget
        .import     show_edit_value
        .import     ss_has_sel
        .import     ss_items
        .import     ss_lr_idx
        .import     ss_pu_entry
        .import     ss_str_idx
        .import     ss_ud_idx
        .import     ss_widget_idx
        .import     ss_y_offset
        .import     ss_width
        .import     type_at_x

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"
        .include    "edit_string.inc"

; tmp5,tmp6,tmp7,tmp8
; ptr1,ptr3,ptr4
.proc handle_kb
        ; get current popup item into our buffer so we can read values
        jsr     load_widget_x

start_kb_get:
        jsr     _kb_get_c_ucase
        cmp     #$00
        beq     start_kb_get

        ; call the kb callback
        ldx     #PopupItemReturn::not_handled    ; default so the main popup kbh can do its thing
        jsr     do_kb_cb

        cpx     #PopupItemReturn::not_handled
        beq     start_pu_kbh

        ; just return the value that the kbh gave us, it will deal with redisplay or exit
        rts

start_pu_kbh:
; --------------------------------------------------------------------
; main popup select  kb switch
; --------------------------------------------------------------------

; valid keys are up/down/enter/esc/tab/left/right/E(dit)

; - enter selects current options that are highlighted
; - ESC always exits with no changes to be made (return '1' in A).
; - tab moves between widgets
; - in an option widget, L/R are allowed, not up/down
; - in a list, U/D allowed, L/R not
; - HOWEVER, the popup item can define which widget allows L/R, U/D movement without it being highlighted.
;   to remove the need to press tab.
; - Non selectable widgets are skipped over when pretting tab.
; - STRING fields:
;      - Press E to Edit it, so like on HOSTS screen.
;      - Popup Item can also define which widget the E key will immediately edit if it isn't currently selected
;      - when not being edit, the entry is just text on screen, when selected, arrows appear and text inverted

; Highlighting:
; - options text is inverted with 2 chars around current option
; - list entry is inverted for entire line
; - String entry is inverted when not editing
;
; Current selected is stored in popupItem.val for each item, 0 index

; --------------------------------------------------------------------
; TAB - switch widget
; --------------------------------------------------------------------
:       cmp     #FNK_TAB
        bne     not_tab

        ; do we have any selectables? e.g. info popups have non, so don't want to get stuck in loop here
        lda     ss_has_sel
        bne     :+
        
        ; ignore tab, as we have no selectable widgets
        beq     start_kb_get

        ; we want to move to next widget that is selectable, with wrap to top if next index = finish
:       jsr     set_next_selectable_widget
        jmp     redisplay

not_tab:
; --------------------------------------------------------------------
; LEFT - option only currently
; --------------------------------------------------------------------
        cmp     #FNK_LEFT
        beq     is_left
        cmp     #FNK_LEFT2
        bne     not_left

is_left:
        jsr     kb_can_do_LR
        bne     :+
        beq     start_kb_get        ; 0 is also PopupHandleKBEvent::no

:       cmp     #PopupHandleKBEvent::other
        beq     :+

        jmp     do_prev
        ; implicit rts

:       ; a different widget can handle it, we have its index already in ss_other_lr_idx
        ; so swap to the other widget index, load its data, and run the prev on it instead, then restore back to ourselves
        ldx     ss_lr_idx
        mwa     #do_prev, ptr3
        jmp     handle_by_other
        ; implicit rts, with result in A

not_left:
; --------------------------------------------------------------------
; RIGHT - option only currently
; --------------------------------------------------------------------
        cmp     #FNK_RIGHT
        beq     is_right
        cmp     #FNK_RIGHT2
        bne     not_right

is_right:
        jsr     kb_can_do_LR
        bne     :+
        beq     start_kb_get

:       cmp     #PopupHandleKBEvent::other
        beq     :+

        jmp     do_next
        ; implicit rts

:       ; a different widget can handle it, we have its index already in ss_other_lr_idx
        ; so swap to the other widget index, load its data, and run the prev on it instead, then restore back to ourselves
        ldx     ss_lr_idx
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
        beq     start_kb_get

:       cmp     #PopupHandleKBEvent::other
        beq     :+

        jmp     do_prev
        ; implicit rts

:       ; other widget
        ldx     ss_ud_idx
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
        ldx     ss_ud_idx
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
        lda     #$00
        ldx     #PopupItemReturn::escape
        rts
not_esc:
; --------------------------------------------------------------------
; ENTER - finish interaction
; --------------------------------------------------------------------
        cmp     #FNK_ENTER
        bne     not_enter

        ; simple, just exit with complete code, the caller will read out any data as needed
        lda     #$00
        ldx     #PopupItemReturn::complete
        rts

not_enter:
; --------------------------------------------------------------------
; EDIT - String field edit
; --------------------------------------------------------------------
        cmp     #FNK_EDIT
        bne     not_edit

        ; is this a string widget? or is there an editable widget?
        jsr     kb_can_do_edit
        bne     :+
        jmp     start_kb_get

:       cmp     #PopupHandleKBEvent::other
        beq     edit_other

        jmp     do_edit
        ; implicit rts

edit_other:
        ; another widget can do editing
        ldx     ss_str_idx
        mwa     #do_edit, ptr3
        jmp     handle_by_other
        ; implicit rts

not_edit:
; --------------------------------------------------------------------
; end of keyboard switch, reloop until ESC or Enter is hit
; --------------------------------------------------------------------
        jmp     start_kb_get

.endproc

.proc pu_null_cb
        rts
.endproc

.proc do_kb_cb
        ;; TODO: make this straight jmp so we don't get the indirect jmp bug!!
        nop
        jmp     (pu_kb_cb)
        ; return from caller will take us back
.endproc

; x = other index to change
; ptr3 = next/prev function to jsr into
.proc handle_by_other
        lda     ss_widget_idx
        pha
        stx     ss_widget_idx
        jsr     load_widget_x
        jsr     do_jmp

        ; reset back to the current index
        pla
        sta     ss_widget_idx
        jsr     load_widget_x
        jmp     redisplay

do_jmp:
        jmp     (ptr3)
        ; the rts in the call will return us back into handle_by_other
.endproc

.proc redisplay
        lda     #$00
        ldx     #PopupItemReturn::redisplay
        rts
.endproc

; read the value of the popup item - indirect pointer so we can use RODATA for all popup item definitions
.proc get_pu_val
        ldy     #$00
        mwa     {ss_pu_entry + POPUP_VAL_IDX}, tmp5
        lda     (tmp5), y
        rts
.endproc

.proc do_next_val
        ; move to next value, rotating if at end
        jsr     get_pu_val
        clc
        adc     #$01
        cmp     ss_pu_entry + POPUP_NUM_IDX
        bcc     :+
        lda     #$00

:       rts
.endproc

.proc do_prev_val
        ; move to previous value, rotating if at end
        jsr     get_pu_val
        sec
        sbc     #$01
        cmp     #$ff
        bne     :+

        ldx     ss_pu_entry + POPUP_NUM_IDX
        dex
        txa

:       rts
.endproc

.proc do_prev
        jsr     do_prev_val
        jmp     copy_ret
.endproc

.proc do_next
        jsr     do_next_val
        jmp     copy_ret
.endproc

.proc do_edit
        ; string to edit
        lda     ss_pu_entry + POPUP_VAL_IDX
        sta     _es_params + EditString::initial_str
        lda     ss_pu_entry + POPUP_VAL_IDX+1
        sta     _es_params + EditString::initial_str + 1

        ; max length
        lda     ss_pu_entry + POPUP_LEN_IDX
        sta     _es_params + EditString::max_length
        lda     #$00
        sta     _es_params + EditString::max_length + 1

        ; x
        lda     #SCR_WIDTH-2
        sec
        sbc     ss_width
        lsr     a       ; divide by 2
        sta     ptr1

        setax   ss_pu_entry + PopupItemString::text
        jsr     _fc_strlen
        clc
        adc     #$03            ; plus 2 for border and left highlight arrow
        adc     ptr1            ; add the offset for the popup width
        sta     _es_params + EditString::x_loc

        ; y
        lda     ss_y_offset     ; add extra for header
        clc
        adc     #$03
        adc     ss_widget_idx
        sta     _es_params + EditString::y_loc

        ; viewport width
        lda     ss_pu_entry + POPUP_VPW_IDX
        sta     _es_params + EditString::viewport_width

        ; if this is a "password" type, pass '1' (true)
        lda     ss_pu_entry     ; first byte is the type
        cmp     #PopupItemType::password
        bne     is_string
        lda     #$01            ; is_password
        bne     :+
is_string:
        lda     #$00
:       sta     _es_params + EditString::is_password

        ; if this is a number type, pass 1 (true)
        lda     ss_pu_entry
        cmp     #PopupItemType::number
        bne     not_number
        lda     #$01            ; is_number
        bne     :+
not_number:
        lda     #$00

:       sta     _es_params + EditString::is_number

        ; everything complete, call edit_string
        jsr     _edit_string
        ; the return is not important, still editing a popup.

        jmp     redisplay
.endproc

.proc copy_ret
        jsr     copy_new_val
        jmp     redisplay
.endproc

.proc kb_can_do_edit
        jsr     get_current_item_type
        cmp     #PopupItemType::string
        beq     kb_edit_yes
        cmp     #PopupItemType::password
        beq     kb_edit_yes
        cmp     #PopupItemType::number
        beq     kb_edit_yes
        
        lda     ss_str_idx
        bmi     :+                              ; $ff means there is no EDIT option on page

        ; only 1 other can handle this key press, but not current widget
        lda     #PopupHandleKBEvent::other      ; indicate there's another widget that can use this press
        rts 

        ; default to NO, if more types need adding, add them above
:       lda     #PopupHandleKBEvent::no
        rts

kb_edit_yes:
        lda     #PopupHandleKBEvent::self       ; indicate this widget can move L/R
        rts
.endproc

.proc kb_can_do_LR
        jsr     get_current_item_type
        cmp     #PopupItemType::option
        beq     kb_lr_yes
        
        lda     ss_lr_idx
        bmi     :+                              ; $ff means there is no U/D option on page

        ; only 1 other can handle this key press, but not current widget
        lda     #PopupHandleKBEvent::other      ; indicate there's another widget that can use this press
        rts 

        ; default to NO, if more types need adding, add them above
:       lda     #PopupHandleKBEvent::no
        rts

kb_lr_yes:
        lda     #PopupHandleKBEvent::self       ; indicate this widget can move L/R
        rts
.endproc

.proc kb_can_do_UD
        jsr     get_current_item_type
        cmp     #PopupItemType::textList
        beq     kb_ud_yes
        
        lda     ss_ud_idx
        bmi     :+                              ; $ff means there is no U/D option on page

        ; only 1 other can handle this key press, but not current widget
        lda     #PopupHandleKBEvent::other      ; indicate there's another widget that can use this press
        rts 

        ; default to NO, if more types need adding, add them above
:       lda     #PopupHandleKBEvent::no
        rts

kb_ud_yes:
        lda     #PopupHandleKBEvent::self       ; indicate this widget can move L/R
        rts

.endproc

.proc copy_new_val
        pha     ; push new value so we can retrieve it after getting to correct item

        ; get location of our widget table into ptr1
        ldx     ss_widget_idx
        jsr     item_x_to_ptr1
        ; now get the location of the VALUE for this widget
        ldy     #POPUP_VAL_IDX
        lda     (ptr1), y
        sta     tmp5
        iny
        lda     (ptr1), y
        sta     tmp6
        ; tmp5/6 points to real memory location to save value into. this will update su_pu_entry as that ALSO points to same location

        ldy     #$00
        pla
        ; save the value into its memory location
        sta     (tmp5), y
        rts
.endproc

; sets ptr1 to current popup item
.proc get_current_item_type
        ldx     ss_widget_idx
        jmp     type_at_x
.endproc

.bss
; pop up keyboard callback vector. Allows callers to setup a callback where they can intercept the kb routine to allow changes
pu_kb_cb:       .res 2