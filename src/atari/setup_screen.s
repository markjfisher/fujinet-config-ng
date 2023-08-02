        .export     _setup_screen, main_dlist
        .include    "atari.inc"
        .include    "inc/antic.inc"
        .include    "fn_macros.inc"

; void setup_screen()
.proc _setup_screen

        jsr init_screen
        mwa #do_vblank,  VVBLKI
        mwa #main_dlist, DLISTL

        mva #$02, CHACTL
        mva #$3c, PACTL

        jmp show_screen

init_screen:
        mva #$00, NMIEN
        jsr wait_scan1
        mva #$00, SDMCTL
        sta       GRACTL
        sta       DMACTL

wait_scan1:
:       lda VCOUNT
        bne :-

:       lda VCOUNT
        beq :-
        rts

show_screen:
        mva #$40, NMIEN
        mva #$22, SDMCTL
        sta       DMACTL
        jsr wait_scan1

        ; dark red central area, brigher outside
        mva #$06, COLPF1    ; glyph pixel luma
        mva #$30, COLPF2    ; b/g
        mva #$00, COLBK     ; border

        rts

do_vblank:
        plr
        rti

.endproc

.segment "DLIST"
main_dlist:
    ; blank lines in head
    .byte DL_BLK8, DL_BLK8

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


.data

    SCREENCODE_CHARMAP
m_l1:   .byte $80, " 123456789012345678901234567890123456 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1          a                       6 ", $80
        .byte $80, " 1          b                       6 ", $80
        .byte $80, " 1          c                       6 ", $80
        .byte $80, " 1          d                       6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 123456789012345678901234567890123456 ", $80

    SCREENCODE_INVERT_CHARMAP
sline1: .byte "  status line1      123456789012345678  "
sline2: .byte "  status line2      123456789012345678  "
mhlp1:  .byte "  help line1        123456789012345678  "
mhlp2:  .byte "  help line2        123456789012345678  "

    NORMAL_CHARMAP