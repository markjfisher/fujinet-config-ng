        .export     _scr_setup

        .import     _bar_clear
        .import     _bar_setup
        .import     _cng_prefs
        .import     _wait_scan1
        .import     m_l1
        .import     main_dlist

        .import     debug

        .include    "atari.inc"
        .include    "cng_prefs.inc"
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

        jsr     debug
        ; set the colors from the preferences data
        lda     _cng_prefs + CNG_PREFS_DATA::colour
        asl     a
        asl     a
        asl     a
        asl     a                       ; $X0
        tax                             ; store it in X
        ; add the brightness value for the colour
        ora     _cng_prefs + CNG_PREFS_DATA::brightness
        sta     COLOR1

        txa                             ; restore $X0
        ; add the shade
        ora     _cng_prefs + CNG_PREFS_DATA::shade
        sta     COLOR2
        sta     COLOR4

        mva     #$08, GPRIOR    ; this sets the priorities correctly for players/missiles when not using pure black background.
        jsr     _wait_scan1     ; at top of screen, everything is now setup

        ; turn screen and interrupts back on with DMA enabled for PMG
        mva     #$40, NMIEN
        mva     #$2e, SDMCTL

        ; setup for the screen location to be usable by cc65's output routines
        mwa     #m_l1, SAVMSC

        rts
.endproc

