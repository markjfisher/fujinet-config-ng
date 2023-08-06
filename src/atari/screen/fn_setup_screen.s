        .export     _fn_setup_screen, main_dlist
        .import     m_l1, sline1, sline2, mhlp1, mhlp2, _wait_scan1, _fn_pause
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
        sta       GRACTL
        sta       DMACTL
        jsr _wait_scan1
        rts

show_screen:
        mva #$40, NMIEN
        mva #$22, SDMCTL
        sta       DMACTL

        ; TODO: move this out elsewhere
        ; dark red central area, brigher outside - also, USE SHADOWs!
        mva #$0a, COLOR1    ; glyph pixel luma
        mva #$30, COLOR2    ; b/g
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
    .byte DL_BLK8, DL_BLK4

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

    ; 2 spacers
    LMS DL_MODEF, gbk, 2

    .byte DL_JVB
    .addr main_dlist

.rodata
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
