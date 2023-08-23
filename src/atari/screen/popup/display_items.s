        .export    display_items

        .import    display_textlist
        .import    display_option
        .import    display_space

        .import    copy_entry

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_popup_item.inc"

; Displays all the PopupItem objects
.proc display_items

l_all_items:
        ; read the next Popup type, if it's last element (finish type) return to caller
        ldy     #PopupItem::type
        lda     (ptr1), y
        cmp     #PopupItemType::finish
        bne     not_last_line
        ; all items done
        rts

not_last_line:
        pha     ; save the type while we read the whole line
        jsr     copy_entry
        pla     ; restore the type

; ----------------------------------------------
; START SWITCH FOR TYPE
; ----------------------------------------------

; --------------------------------------------------
; TEXT LIST
        cmp     #PopupItemType::textList
        bne     not_text_list

        jsr     display_textlist
        jmp     next_item

not_text_list:
; --------------------------------------------------
; OPTION
        cmp     #PopupItemType::option
        bne     not_option

        jsr     display_option
        jmp     next_item

not_option:
; --------------------------------------------------
; BLANK LINE (space)
        cmp     #PopupItemType::space
        bne     not_space

        jsr     display_space

        ; UNCOMMENT IF MORE OPTIONS IMPLEMENTED
        ; jmp     next_item

not_space:
; TODO: IMPLEMENT OTHER PopupItemType TYPES 


next_item:
        adw     ptr1, #.sizeof(PopupItem)       ; move ptr1 to next popup entry
        adw     ptr4, #40                       ; add 40 to screen location to point to next line
        jmp     l_all_items

.endproc