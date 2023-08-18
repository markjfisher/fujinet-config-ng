        .export     _fn_pause
        .import     getax

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void _fn_pause(uint8 jiffies)
;
; wait for clock to cycle to given count 0-255
.proc _fn_pause
        sta    tmp1

        ; this may need to change if we do more complicated timings elsewhere
        ; but for now, we set RTCLOK+2 to 0, and wait until it hits jiffies
        lda     #$00
        sta     RTCLOK+2

:       lda     RTCLOK+2
        cmp     tmp1
        bne     :-

        rts
.endproc
