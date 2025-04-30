
        .export     main_dlist
        .export     m_l1, sline1, sline2, mhlp1
        .export     gbk, gintop1, gintop2, gouttop1, gouttop2

        .include    "atari.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

; Convenience defines

DL_MODE2      = $02
DL_MODE3      = $03
DL_MODE4      = $04
DL_MODE5      = $05
DL_MODE6      = $06
DL_MODE7      = $07
DL_MODE8      = $08
DL_MODE9      = $09
DL_MODEA      = $0A
DL_MODEB      = $0B
DL_MODEC      = $0C
DL_MODED      = $0D
DL_MODEE      = $0E
DL_MODEF      = $0F


.segment "DLIST"

main_dlist:
    ; blank lines in head, last one has a DLI on it
    .byte DL_BLK8, DL_BLK2 | DL_DLI
    LMS DL_MODEF, gouttop1
    LMS DL_MODEF, gouttop2, 2

    ; 2 spacers (40 x $ff)
    LMS DL_MODEF, gbk, 2

    ; status line
    LMS DL_MODE2, sline1
    LMS DL_MODE2, sline2
    
    ; 2 spacers (40 x $ff)
    LMS DL_MODEF, gbk, 2

    ; inner curve open above main display
    LMS DL_MODEF, gintop1
    .byte DL_MODEF
    LMS DL_MODEF, gintop2

    LMS DL_MODE2, m_l1
    .repeat SCR_HEIGHT-1
    .byte DL_MODE2
    .endrepeat

    ; inner curve close
    LMS DL_MODEF, gintop2, 2
    LMS DL_MODEF, gintop1

    ; 2 spacers (40 x $ff)
    LMS DL_MODEF, gbk, 2

    LMS DL_MODE2, mhlp1

    LMS DL_MODEF, gouttop2, 2
    LMS DL_MODEF, gouttop1

    .byte DL_JVB
    .addr main_dlist

; this also mustn't cross a boundary? get corruption if any of the rounding data goes over a 4k (e.g. put into rodata and it might fail)
; following 200 bytes are curvature lines on the screen.
gbk:
    .repeat 40
        .byte $ff
    .endrepeat

gintop1:
    .byte $fe
    .repeat 38
        .byte $00
    .endrepeat
    .byte $7f

gintop2:
    .byte $f8
    .repeat 38
        .byte $00
    .endrepeat
    .byte $1f

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


;; Addresses of Screen Memory - no need to assign it data
;; as it will be cleared at start, and doesn't need to be in the segment
.segment "SCREEN"
scr_start_addr = *
sline1 = scr_start_addr
sline2 = sline1 + SCR_BYTES_W
m_l1   = sline2 + SCR_BYTES_W
mhlp1  = m_l1 + (SCR_BYTES_W * SCR_HEIGHT)
