        .export     _fn_io_error

        .include    "fn_data.inc"

; int _fn_io_error()
;
; sets A=0 (and Z=1) if there is no error, 127 ($80) otherwise
.proc _fn_io_error
        ldx #$00
        lda IO_DCB::dstats
        and #$80
        rts
.endproc