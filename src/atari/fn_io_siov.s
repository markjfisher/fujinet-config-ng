        .export _fn_io_siov
        .import _fn_io_copy_dcb
        .include "atari.inc"

; void _fn_io_siov(dcb_table)
;
; Sets DCB data from passed in dcb_table and calls SIOV
.proc _fn_io_siov
        jsr     _fn_io_copy_dcb
        jmp     SIOV
.endproc
