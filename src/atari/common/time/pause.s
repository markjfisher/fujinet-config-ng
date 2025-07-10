        .export     _pause

        .include    "atari.inc"
        .include    "zeropage.inc"

; void _pause(uint8_t jiffies)
;
; wait for clock to cycle by the given count 0-255
.proc _pause
        clc
        adc     RTCLOK+2
        sta     tmp1        ; target timer value to get. don't care about carry, as we are just comparing a byte that cycles anyway

        ; now loop until we match the required time
:       lda     RTCLOK+2
        cmp     tmp1
        bne     :-

        rts
.endproc