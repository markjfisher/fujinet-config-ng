        .export     m_l1, sline1, sline2, sline3, mhlp1, mhlp2
        ; .export     mhlp3, mhlp4
        .export     gbk, gintop1, gintop2, gouttop1, gouttop2
        .export     s_empty
        .include    "fn_macros.inc"

.segment "SCREEN"

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
m_l1:   .repeat 9
            SCREEN_BLANK_LINE
        .endrepeat
        NORMAL_CHARMAP
m_mid1: .byte $80, $cc
        .repeat 36
            .byte $55
        .endrepeat
        .byte $cf, $80
        SCREENCODE_INVERT_CHARMAP
m_mid2: SPACES_40
        NORMAL_CHARMAP
m_mid3: .byte $80, $ca
        .repeat 36
            .byte $d5
        .endrepeat
        .byte $cb, $80
        SCREENCODE_CHARMAP
m_btm:  .repeat 9
            SCREEN_BLANK_LINE
        .endrepeat

        SCREENCODE_INVERT_CHARMAP
; needs to be continuous memory for screen writers
mhlp1:  SPACES_40
mhlp2:  SPACES_40
; mhlp3:  SPACES_40
; mhlp4:  SPACES_40
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

s_empty:
    .byte "<Empty>", 0
