        .export io_siov
        .import io_copy_dcb
        .include "atari.inc"

; void io_siov(dcb_table)
;
; Sets DCB data from passed in dcb_table and calls SIOV
.proc io_siov
        jsr     io_copy_dcb
        jmp     SIOV
.endproc
