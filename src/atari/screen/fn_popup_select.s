        .export     _fn_popup_select

        .import     popax, popa

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"

.struct PopupItem
        type    .byte
        
.endstruct

; void fn_popup_select(char *msg, void *selected)
; 
; display a list of items, and show the values, allowing user to select from it
; using inverted text for selection
.proc _fn_popup_select
        axinto  fps_selected            ; address where to set the selected line index so it can be read on completion of popup
        popax   fps_kb_handler          ; a kb handler to process key strokes while popup active
        popax   fps_message             ; the header message to display in popup
        popax   fps_list                ; pointer to the list of PopupItem to display. A PopupItem has a type (Text, option etc)
        popa    fps_width               ; the width of the input area excluding the borders which add 2 each side (space and border)

        ; we need to loop fps_list count + 2 (add top and bottom)
        ; and add border around editable area
        ; border characters are:
        ; 06 80 * (width + 2) 07
        ; 80                  80
        ; ...  * list-count lines
        ; 08 80 * (width + 2) 09
        ; which leaves a box in middle size width+2 x height



        rts
.endproc

.bss
fps_selected:   .res 2
fps_kb_handler: .res 2
fps_message:    .res 2
fps_list:       .res 2
fps_width:      .res 1
fps_lines:      .res 1
