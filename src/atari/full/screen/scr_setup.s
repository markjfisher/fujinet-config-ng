        .export     _scr_setup

        .import     _bar_clear
        .import     _bar_setup
        .import     _wait_scan1
        .import     main_dlist

        .include    "atari.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

; void scr_setup()
.proc _scr_setup

        jsr     _wait_scan1
        mva     #$00, SDMCTL
        mva     #$00, NMIEN
        jsr     _wait_scan1

        jsr     _bar_setup
        jsr     _bar_clear

        mwa     #main_dlist, SDLSTL

        mva     #$02, CHACTL
        mva     #$3c, PACTL

        ; setup some colors
        mva     #$0d, COLOR1    ; glyph pixel luma
        mva     #$00, COLOR2    ; b/g
        sta           COLOR4    ; border
        jsr     _wait_scan1     ; at top of screen, everything is now setup

        ; turn screen and interrupts back on with DMA enabled for PMG
        mva     #$40, NMIEN
        mva     #$2e, SDMCTL

        rts
.endproc

