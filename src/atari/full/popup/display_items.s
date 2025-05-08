        .export    display_items
        .export    di_current_item

        .import    display_option
        .import    display_string
        .import    display_space
        .import    display_text
        .import    display_textlist

        .import    ss_args
        .import    ss_num_lr
        .import    ss_other_lr_idx
        .import    ss_num_ud
        .import    ss_other_ud_idx
        .import    copy_entry

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

; Displays all the PopupItem objects
; ptr1,ptr4
.proc display_items
        mwa     ss_args+ShowSelectArgs::items, ptr1     ; set ptr1 to first popup item to display. it will walk down the list
        mva     #$00, di_current_item                   ; this tracks which item is currently being displayed so we can compare to selected

l_all_items:
        ; read the next Popup type, if it's last element (finish type) return to caller
        ldy     #POPUP_TYPE_IDX
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

; all widget displays return 0 in A/X, so we can beq

; TODO: use dispatch based on PopupItemType rather than switch style using cmp

; --------------------------------------------------
; TEXT LIST
        cmp     #PopupItemType::textList
        bne     not_text_list

        adw1    ptr1, #.sizeof(PopupItemTextList)
        jsr     display_textlist
        beq     next_item

not_text_list:
; --------------------------------------------------
; OPTION
        cmp     #PopupItemType::option
        bne     not_option

        adw1    ptr1, #.sizeof(PopupItemOption)
        jsr     display_option
        beq     next_item

not_option:
; --------------------------------------------------
; BLANK LINE (space)
        cmp     #PopupItemType::space
        bne     not_space

        adw1    ptr1, #.sizeof(PopupItemSpace)
        jsr     display_space
        beq     next_item

not_space:
; --------------------------------------------------
; TEXT LINES (text)
        cmp     #PopupItemType::text
        bne     not_text

        adw1    ptr1, #.sizeof(PopupItemText)
        jsr     display_text
        ; fall into next_item

; ==================================================
; put in the middle so it can be reached by more options
; ==================================================

next_item:
        inc     di_current_item                 ; increment the current item being displayed
        ; ptr1 moves to next widget in each type above
        ; move ptr4 along to next start of line
        adw1    ptr4, #SCR_BYTES_W
        jmp     l_all_items


not_text:
; --------------------------------------------------
; EDITABLE STRING (string)
        cmp     #PopupItemType::string
        bne     not_string

        adw1    ptr1, #.sizeof(PopupItemString)
        jsr     display_string
        beq     next_item

; --------------------------------------------------
; EDITABLE PASSWORD (password)
not_string:
        cmp     #PopupItemType::password
        bne     not_password

        adw1    ptr1, #.sizeof(PopupItemPassword)
        jsr     display_string
        beq     next_item

; --------------------------------------------------
; EDITABLE NUMBER (number)
not_password:
        cmp     #PopupItemType::number
        bne     next_item               ; CHANGE THIS IF MORE OPTIONS ADDED

        adw1    ptr1, #.sizeof(PopupItemNumber)
        jsr     display_string
        beq     next_item

not_number:



; HERE: IMPLEMENT OTHER PopupItemType VALUES


.endproc

.bss
di_current_item:        .res 1