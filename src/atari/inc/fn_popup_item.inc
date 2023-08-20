.struct PopupItem
        type    .byte           ; the widget type
        num     .byte           ; number of them
        len     .byte           ; length of each individual text entry
        val     .byte           ; chosen option/select. if checkbox, bit number is on if option set, so limited to 8 checkboxes
        text    .word           ; ptr to first string (null terminated) of num strings
.endstruct

; a bit like html widgets
.enum PopupItemType
        textList                ; simple text list display
        textListReadOnly        ; simple text list, text is editable
        option                  ; like radio buttons, only 1 can be selected
        select                  ; drop down select
        checkbox                ; individual on/off
        button                  ; highlight it and press enter to enact
        finish                  ; marker that we have finished items             
.endenum
