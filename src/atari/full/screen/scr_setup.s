        .export     _scr_setup, main_dlist
        .export     m_l1, sline1, sline2, mhlp1, mhlp2
        .export     gbk, gintop1, gintop2, gouttop1, gouttop2

        .import     _pause, _wait_scan1, _bar_setup, _bar_clear

        .include    "atari.inc"
        .include    "fn_macros.inc"

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

; void scr_setup()
.proc _scr_setup

        ; Screen is already off in the pre_init stage.
        mva #$00, NMIEN
        jsr _bar_setup
        jsr _bar_clear

        mwa #main_dlist, SDLSTL

        mva #$02, CHACTL
        mva #$3c, PACTL

        ; setup some colors
        mva #$0d, COLOR1    ; glyph pixel luma
        mva #$00, COLOR2    ; b/g
        mva #$00, COLOR4    ; border
        jsr _wait_scan1     ; at top of screen, everything is now setup

        ; turn screen and interrupts back on with DMA enabled for PMG
        mva #$40, NMIEN
        mva #$2e, SDMCTL

        rts
.endproc

.segment "DLIST"

main_dlist:
    ; blank lines in head
    .byte DL_BLK8, DL_BLK2
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
    .repeat 19
    .byte DL_MODE2
    .endrepeat

    ; inner curve close
    LMS DL_MODEF, gintop2, 2
    LMS DL_MODEF, gintop1

    ; 2 spacers (40 x $ff)
    LMS DL_MODEF, gbk, 2

    LMS DL_MODE2, mhlp1
    LMS DL_MODE2, mhlp2

    LMS DL_MODEF, gouttop2, 2
    LMS DL_MODEF, gouttop1

    .byte DL_JVB
    .addr main_dlist

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
        NORMAL_CHARMAP

        SCREENCODE_CHARMAP
m_l1:   .repeat 20
            SCREEN_BLANK_LINE
        .endrepeat


        SCREENCODE_INVERT_CHARMAP
; needs to be continuous memory for screen writers
mhlp1:  SPACES_40
mhlp2:  SPACES_40
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
