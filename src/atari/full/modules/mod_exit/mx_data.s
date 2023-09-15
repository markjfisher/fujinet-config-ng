        .export     booting_mode
        .export     boot_anim_1_1
        .export     boot_anim_1_2
        .export     boot_anim_1_3
        .export     boot_anim_2_1
        .export     mx_ask_lobby_info
        .export     mx_ask_lobby_option
        .export     mx_ask_pu_msg

        .include    "fc_macros.inc"
        .include    "fc_mods.inc"
        .include    "popup.inc"

.bss
booting_mode:        .res 1

.segment "SCR_DATA"

; Mounting All - in box
boot_anim_1_1:  .byte $11, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $05, 0
boot_anim_1_2:  .byte $7C, $99, $CD, $EF, $F5, $EE, $F4, $E9, $EE, $E7, $A0, $C1, $EC, $EC, $19, $7C, 0
boot_anim_1_3:  .byte $1A, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $03, 0

; Booting!
boot_anim_2_1:  .byte $7C, $99, $A0, $A0, $C2, $EF, $EF, $F4, $E9, $EE, $E7, $A1, $A0, $A0, $19, $7C, 0

.data
mx_ask_lobby_info:
                ; width, y-offset, has_selectable, up/down option (none), l/r option index
                .byte 18, 2, 1, $ff, 2
                .byte PopupItemType::string, 1, <mx_ask_msg, >mx_ask_msg
                .byte PopupItemType::space
mx_ask_lobby_option:
                ; num, len, val, #texts, #space
                .byte PopupItemType::option, 2, 3, 0, <mx_ask_txt, >mx_ask_txt, <mx_ask_opt, >mx_ask_opt
                .byte PopupItemType::finish

.segment "SCR_DATA"
                NORMAL_CHARMAP
mx_ask_msg:
                .byte "    Boot Lobby?", 0

mx_ask_txt:
                .byte 0         ; no "name" string to show, just want Y/N
                .byte " Y "
                .byte " N "

; sum of these, plus the strings above must add up to the _info "width" above
; 0 + 3 + 3 (name + Y + N) + 3 + 6 + 3 = 18
mx_ask_opt:     .byte 3, 6, 3

mx_ask_pu_msg:  .byte "Lobby", 0
