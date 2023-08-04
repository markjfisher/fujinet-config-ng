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

.macro SPACES_40
        .repeat 40
            .byte " "
        .endrepeat
.endmacro

        SCREENCODE_CHARMAP
m_l1:   .repeat 16
            SCREEN_BLANK_LINE
        .endrepeat

        SCREENCODE_INVERT_CHARMAP
sline1: SPACES_40
sline2: SPACES_40

; we need the addresses for DL, but they also need to be continuous for _fn_put_help which only needs first address
mhlp1:  SPACES_40
mhlp2:  SPACES_40
; TODO: add more help lines as needed
; mhlp3:  SPACES_40
        NORMAL_CHARMAP
