; generic information for PopupItems

; type    .byte           ; the widget type
; num     .byte           ; number of them
; len     .byte           ; length of each individual text entry
; val     .word           ; ptr to memory location to store chosen value for this widget
; text    .word           ; ptr to strings to use, type specific arrangement.
; spc     .word           ; ptr to table of num+1 spacing values for placing widget on screen
; x_off   .byte           ; left padding to apply

; for allocating space to work with popups, need largest struct size
POPUP_MAX_SZ    := 9

; type is always first byte
POPUP_TYPE_IDX  := 0

; for any selectable item (see pui_is_selectable), the NUM/LEN/VAL values must be at these indexes
POPUP_NUM_IDX   := 1
POPUP_LEN_IDX   := 2
POPUP_VAL_IDX   := 3            ; word pointer to memory value

.struct PopupItemInfo
        width   .byte           ; the width of the input area excluding the borders which add 1 each side for the border
        y_off   .byte           ; number of lines from top to add for popup
        has_sel .byte           ; 1 if there are any selectable widgets, 0 if info type
        ud_idx  .byte           ; the entry index to use for Up / Down move if current doesn't support it. $ff for none
        lr_idx  .byte           ; the entry index to use for Left / Right move if current doesn't support it. $ff for none
        str_idx .byte           ; the index to use for E (Edit) to edit string
.endstruct

.struct PopupItemTextList
        type    .byte
        num     .byte
        len     .byte
        val     .word
        text    .word
        x_off   .byte
.endstruct

.struct PopupItemOption
        type    .byte
        num     .byte
        len     .byte
        val     .word
        text    .word
        spc     .word
.endstruct

.struct PopupItemText
        type    .byte
        num     .byte
        text    .word
.endstruct

.struct PopupItemString
        type    .byte
        num     .byte
        len     .byte
        val     .word
        text    .word
.endstruct

.struct PopupItemSpace
        type    .byte
.endstruct

.struct PopupItemFinish
        type    .byte
.endstruct

; a bit like html widgets
.enum PopupItemType
        finish                  ; marker that we have finished items             
        space                   ; just a line of space
        textList                ; simple text list display with numbers, non editable, but selectable
        option                  ; like radio buttons, only 1 can be selected
        text                    ; a non selectable string to be displayed on line. num determines number of strings to display
        string                  ; editable string

        ; select                  ; drop down select
        ; checkbox                ; individual on/off
        ; button                  ; highlight it and press enter to enact - a 1 item option with no "name" will do for this
.endenum

.enum PopupItemReturn
        escape                  ; exit popup, don't make changes
        complete                ; enter was hit and options selection complete, exit with changes
        redisplay               ; nothing chosen yet, just navigating around and need to redisplay the options screen.
        not_handled             ; popup kb callback didn't do anything
.endenum

; This is to allow a keyboard press to be processed by other widgets
; e.g. if you are currently editing an UP/DOWN list, but press L or R, and there is 1 option widget on the popup, then allow it to be handled by the option widget
; which means users don't HAVE to press tab to change context to target widget to change it.
.enum PopupHandleKBEvent
        no                      ; the KB press can't be handled in this popup with the currently selected widget or any other
        self                    ; yes, the current widget handles this kb press
        other                   ; yes, but by another widget, and there's only 1 other widget that could handle it
.endenum
