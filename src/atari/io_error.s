        .export     io_error
        .include    "atari.inc"

; int io_error()
;
; sets A=0 (and Z=1) if there is no error, 127 ($80) otherwise
.proc io_error
        lda DSTATS
        and #$80
        ldx #$00
        rts
.endproc