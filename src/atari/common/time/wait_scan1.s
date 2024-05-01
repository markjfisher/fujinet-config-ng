        .export    _wait_scan1
        .include    "atari.inc"
        .include    "macros.inc"

; void _wait_scan1()
;
; pauses until we hit VCOUNT == 1, i.e. scanline 1
.proc _wait_scan1
:       lda VCOUNT
        bne :-

:       lda VCOUNT
        beq :-
        rts
.endproc
