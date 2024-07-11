        .export     mi_selected
        .export     pre_hex_str
        .export     temp_num

; ##########################################################
.data

; the currently selected field
mi_selected:    .byte 0

; a string that is built up to display on page for preference values
temp_num:       .byte 0, 0, 0   ; our value string of 2 bytes


; ##########################################################
.rodata

; fixed string "0x" to put in front of hex values
pre_hex_str:    .byte "0x", 0