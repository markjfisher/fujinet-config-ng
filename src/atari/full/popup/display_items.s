        .export    display_items
        .export    di_current_item

        .import    display_textlist
        .import    display_option
        .import    display_space
        .import    display_string

        .import    ss_items
        .import    ss_num_lr
        .import    ss_other_lr_idx
        .import    ss_num_ud
        .import    ss_other_ud_idx
        .import    copy_entry

        .include    "fc_zp.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

; Displays all the PopupItem objects
.proc display_items
        mwa     ss_items, ptr1          ; set ptr1 to first popup item to display. it will walk down the list
        mva     #$00, di_current_item   ; this tracks which item is currently being displayed so we can compare to selected

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
; STRING LINES (string)
        cmp     #PopupItemType::string
        bne     not_string

        adw1    ptr1, #.sizeof(PopupItemString)
        jsr     display_string
        ; beq     next_item

not_string:

; TODO: IMPLEMENT OTHER PopupItemType VALUES 

next_item:
        inc     di_current_item                 ; increment the current item being displayed
        ; ptr1 moves to next widget in each type above
        adw1    ptr4, #SCR_BYTES_W
        jmp     l_all_items

.endproc

.bss
di_current_item:        .res 1