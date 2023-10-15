        .export     _pause

        .include    "atari.inc"
        .include    "zp.inc"
        .include    "macros.inc"

; void _pause(uint8_t jiffies)
;
; wait for clock to cycle to given count 0-255
.proc _pause
        sta    tmp6

        ; this may need to change if we do more complicated timings elsewhere
        ; but for now, we set RTCLOK+2 to 0, and wait until it hits jiffies
        lda     #$00
        sta     RTCLOK+2

:       lda     RTCLOK+2
        cmp     tmp6
        bne     :-

        rts
.endproc
