        .export     cng_gotoxy

        .include    "atari.inc"

; inputs:
; a = x position on screen (0 based)
; x = y position on screen (0 based)

cng_gotoxy:
        stx     ROWCRS
        sta     COLCRS
        lda     #$00
        sta     COLCRS+1
        rts
