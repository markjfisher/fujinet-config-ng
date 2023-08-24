        .export     pre_init
        .import     _reset_handler, detect_banks, setup_fonts
        .include    "atari.inc"
        .include    "fn_macros.inc"

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
        mwa     DOSINI, _reset_handler+1
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

        ldx     #$02        ; CLOSE "E"
        jsr     editor
        ldx     #$00        ; OPEN "E"
editor:
        ; dispatch based JMP!
        lda     EDITRV+1, x
        pha
        lda     EDITRV, x
        pha
        ; now ready to JMP on a RTS
ramok:
        rts

clear_from:
.endproc