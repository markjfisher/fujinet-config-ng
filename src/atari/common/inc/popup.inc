.struct PopupItem
        type    .byte           ; the widget type
        num     .byte           ; number of them
        len     .byte           ; length of each individual text entry
        val     .byte           ; chosen option/select. if checkbox, bit number is on if option set, so limited to 8 checkboxes
        text    .word           ; ptr to strings to use, type specific arrangement.
        spc     .word           ; ptr (or null) to table of num+1 spacing values for placing widget on screen
.endstruct

; a bit like html widgets
.enum PopupItemType
        textList                ; simple text list display with numbers
        option                  ; like radio buttons, only 1 can be selected
        ; select                  ; drop down select
        ; checkbox                ; individual on/off
        ; button                  ; highlight it and press enter to enact - a 1 item option with no "name" will do for this
        space                   ; just a line of space
        finish                  ; marker that we have finished items             
.endenum

.enum PopupItemReturn
        escape                  ; exit popup, don't make changes
        complete                ; enter was hit and options selection complete, exit with changes
        redisplay               ; nothing chosen yet, just navigating around and need to redisplay the options screen.
.endenum

; This is to allow a keyboard press to be processed by other widgets
; e.g. if you are currently editing an UP/DOWN list, but press L or R, and there is 1 option widget on the popup, then allow it to be handled by the option widget
; which means users don't HAVE to press tab to change context to target widget to change it.
.enum PopupHandleKBEvent
        no                      ; the KB press can't be handled in this popup with the currently selected widget or any other
        self                    ; yes, the current widget handles this kb press
        other                   ; yes, but by another widget, and there's only 1 other widget that could handle it
.endenum