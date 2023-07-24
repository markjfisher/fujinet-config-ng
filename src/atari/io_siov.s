; io_siov.s

        .export io_siov
        .import io_copy_dcb
        .include "atari.inc"

; Sets DCB and calls SIOV
; INPUT:
;       x = index of io function
.proc io_siov
        jsr io_copy_dcb
        jmp SIOV
.endproc
