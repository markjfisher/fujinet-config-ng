        .export     _fn_pause

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void _fn_pause(uint8_t jiffies)
;
; wait for clock to cycle to given count 0-255
.proc _fn_pause
        sta    _fn_pause_count

        ; this may need to change if we do more complicated timings elsewhere
        ; but for now, we set RTCLOK+2 to 0, and wait until it hits jiffies
        lda     #$00
        sta     RTCLOK+2

:       lda     RTCLOK+2
        cmp     _fn_pause_count
        bne     :-

        rts
.endproc

.bss
_fn_pause_count: .res 1