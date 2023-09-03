        .export    _wait_scan1, _wait_scan0
        .include    "atari.inc"
        .include    "fn_macros.inc"

; void _wait_scan1()
;
; pauses until we hit VCOUNT == 1, i.e. scanline 1
.proc _wait_scan1
        jsr _wait_scan0

:       lda VCOUNT
        beq :-
        rts
.endproc

.proc _wait_scan0
:       lda VCOUNT
        bne :-
        rts
.endproc
