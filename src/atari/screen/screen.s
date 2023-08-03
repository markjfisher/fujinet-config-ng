        .export     m_l1, sline1, sline2, mhlp1, mhlp2
        .include    "fn_macros.inc"

.data

; inverse space + 38 spaces + inverse space.
.macro SCREEN_BLANK_LINE
        .byte $80
        .repeat 38
            .byte " "
        .endrepeat
        .byte $80
.endmacro

        SCREENCODE_CHARMAP
m_l1:   .repeat 16
            SCREEN_BLANK_LINE
        .endrepeat

        SCREENCODE_INVERT_CHARMAP
sline1: .byte "  status line1      123456789012345678  "
sline2: .byte "  status line2      123456789012345678  "
mhlp1:  .byte "  help line1        123456789012345678  "
mhlp2:  .byte "  help line2        123456789012345678  "

        NORMAL_CHARMAP