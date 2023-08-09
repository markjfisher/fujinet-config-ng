        .export     _fn_setup_screen, main_dlist
        .import     m_l1, sline1, sline2, sline3, mhlp1, mhlp2, mhlp3, mhlp4
        .import     gbk, gintop1, gintop2, gouttop1, gouttop2
        .import     _fn_pause, _wait_scan1, _bar_setup, _bar_clear
        .include    "atari.inc"
        .include    "fn_antic.inc"
        .include    "fn_macros.inc"

; void _fn_setup_screen()
.proc _fn_setup_screen

        jsr init_screen
        mwa #main_dlist, SDLSTL

        mva #$02, CHACTL
        mva #$3c, PACTL

        jmp show_screen

init_screen:
        mva #$00, NMIEN
        jsr _wait_scan1
        mva #$00, SDMCTL
        jsr _bar_setup
        jsr _bar_clear
        jsr _wait_scan1
        rts

show_screen:
        mva #$40, NMIEN
        mva #$2e, SDMCTL

        ; TODO: move this out elsewhere
        ; dark red central area, brigher outside - also, USE SHADOWs!
        ; mva #$0d, COLOR1    ; glyph pixel luma
        ; mva #$50, COLOR2    ; b/g
        ; mva #$50, COLOR4    ; border
        mva #$0d, COLOR1    ; glyph pixel luma
        mva #$00, COLOR2    ; b/g
        mva #$00, COLOR4    ; border

        ; above or below colors?
        lda #2
        jsr _fn_pause
        jsr _wait_scan1

        rts
.endproc

.segment "DLIST"
main_dlist:
    ; blank lines in head
    .byte DL_BLK8, DL_BLK6
    LMS DL_MODEF, gouttop1
    LMS DL_MODEF, gouttop2, 2

    ; 2 spacers (40 x $ff)
    LMS DL_MODEF, gbk, 2

    ; status line
    LMS DL_MODE2, sline1
    LMS DL_MODE2, sline2
    LMS DL_MODE2, sline3
    
    ; 2 spacers (40 x $ff)
    LMS DL_MODEF, gbk, 2

    ; inner curve open above main display
    LMS DL_MODEF, gintop1
    .byte DL_MODEF
    LMS DL_MODEF, gintop2

    LMS DL_MODE2, m_l1
    .repeat 15
    .byte DL_MODE2
    .endrepeat

    ; inner curve close
    LMS DL_MODEF, gintop2, 2
    LMS DL_MODEF, gintop1

    ; 2 spacers (40 x $ff)
    LMS DL_MODEF, gbk, 2

    LMS DL_MODE2, mhlp1
    LMS DL_MODE2, mhlp2
    LMS DL_MODE2, mhlp3
    LMS DL_MODE2, mhlp4

    LMS DL_MODEF, gouttop2, 2
    LMS DL_MODEF, gouttop1

    .byte DL_JVB
    .addr main_dlist
