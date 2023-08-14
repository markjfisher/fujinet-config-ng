        .export         _fn_io_reset
        .import         _fn_io_siov
        .include        "fn_macros.inc"
        .include        "fn_io.inc"

; void  _fn_io_reset()
; resets FN. Up to the caller to pause afterwards
.proc _fn_io_reset
        setax   #t_io_reset
        jmp     _fn_io_siov
.endproc

.rodata

t_io_reset:
        .byte $ff, $40, $00, $00, $0f, $00, $00, $00, $00, $00
