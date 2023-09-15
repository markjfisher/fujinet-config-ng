        .export     booting_mode
        .export     boot_anim_1_1
        .export     boot_anim_1_2
        .export     boot_anim_1_3
        .export     boot_anim_2_1

.bss
booting_mode:        .res 1

.segment "SCR_DATA"

; Mounting All - in box
boot_anim_1_1: .byte $11, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $05, 0
boot_anim_1_2: .byte $7C, $99, $CD, $EF, $F5, $EE, $F4, $E9, $EE, $E7, $A0, $C1, $EC, $EC, $19, $7C, 0
boot_anim_1_3: .byte $1A, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $03, 0

; Booting!
boot_anim_2_1: .byte $7C, $99, $A0, $A0, $C2, $EF, $EF, $F4, $E9, $EE, $E7, $A1, $A0, $A0, $19, $7C, 0