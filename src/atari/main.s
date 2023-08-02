        .export _main
        .import _setup_screen, run_module, pusha, put_digit
        .include "fn_macros.inc"

.proc _main
        jsr     _setup_screen
        ; jsr     run_module

        ; quick test of printing "5" at 3,3
        lda #3
        jsr pusha
        lda #3
        jsr pusha
        lda #5
        jsr put_digit

:       jmp :-

.endproc