        .export     m_l1, sline1, sline2, sline3, mhlp1, mhlp2, mhlp3, mhlp4
        .export     gbk, gintop1, gintop2, gouttop1, gouttop2
        .include    "fn_macros.inc"

.segment "SDATA"

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

        SCREENCODE_INVERT_CHARMAP
sline1: SPACES_40
sline2: SPACES_40
sline3: SPACES_40
        NORMAL_CHARMAP

        SCREENCODE_CHARMAP
m_l1:   .repeat 16
            SCREEN_BLANK_LINE
        .endrepeat


        SCREENCODE_INVERT_CHARMAP
; needs to be continuous memory for screen writers
mhlp1:  SPACES_40
mhlp2:  SPACES_40
mhlp3:  SPACES_40
mhlp4:  SPACES_40
        NORMAL_CHARMAP

gbk:
    .repeat 40
        .byte $ff
    .endrepeat

gintop1:
    .byte $ff, $e0
    .repeat 36
        .byte $00
    .endrepeat
    .byte $07, $ff

gintop2:
    .byte $ff, $80
    .repeat 36
        .byte $00
    .endrepeat
    .byte $01, $ff

gouttop1:
    .byte $0f, $ff
    .repeat 36
        .byte $ff
    .endrepeat
    .byte $ff, $f0

gouttop2:
    .byte $3f, $ff
    .repeat 36
        .byte $ff
    .endrepeat
    .byte $ff, $fc
