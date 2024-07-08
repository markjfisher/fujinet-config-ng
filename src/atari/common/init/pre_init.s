        .export     pre_init

        .import     _reset_handler
        .import     detect_banks
        .import     setup_fonts

        .include    "atari.inc"
        .include    "macros.inc"

; https://www.wudsn.com/index.php/productions-atari800/tutorials/tips

; this segment is loaded during disk load before dlist and main are loaded
; the memory location will be written over by later blocks, which is fine, it's only needed for one time initial setup

.segment "INIT"

.proc pre_init
        ; detect banked values for NMIEN for up to MAX_BANKS (defined in detect_banks.s)
        jsr     detect_banks

        ; copy fonts so the change fonts data isn't kept in RAM
        jsr     setup_fonts

        ; setup reset handler
        mwa     DOSINI, _reset_handler+1+3
        mwa     #_reset_handler, DOSINI
        ; this was required before fixing picoboot.bin in CONFIG, by adding equivalent change.
        ; mva     #$01, BOOTQ                     ; stops RESET going to Self Test every other push of button.

        lda     #$c0        ; check if ramtop is already ok
        cmp     RAMTOP
        beq     ramok
        sta     RAMTOP      ; set ramtop to end of basic
        sta     RAMSIZ      ; and ramsiz too

        lda     PORTB
        ora     #$02        ; disable basic bit
        sta     PORTB

        lda     #$01        ; keep it off after reset
        sta     BASICF

ramok:
        rts

clear_from:
.endproc