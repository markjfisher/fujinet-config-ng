; io_error.s
;
; sets A=0 (and Z=1) if there is no error, 127 ($80) otherwise

        .export     io_error
        .include    "atari.inc"

.proc io_error
        lda DSTATS
        and #$80
        rts
.endproc