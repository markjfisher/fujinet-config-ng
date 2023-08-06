        .export     pre_init
        .import     _reset_handler
        .include    "atari.inc"
        .include    "fn_macros.inc"

; https://www.wudsn.com/index.php/productions-atari800/tutorials/tips

; this segment is loaded during disk load before dlist and main are loaded
; the memory location will be written over by later blocks, which is fine, it's only needed to switch off basic

.segment "PREINIT"
.proc pre_init
        ; setup reset handler
        mwa     DOSINI, _reset_handler+1
        mwa     #_reset_handler, DOSINI
        mva     #$01, BOOTQ                     ; stops RESET going to Self Test every other push of button.

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

.endproc