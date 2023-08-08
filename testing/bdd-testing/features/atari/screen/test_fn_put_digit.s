        .export         _main, t_x, t_y, t_d
        .import         _fn_put_digit

        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "zeropage.inc"

.proc _main
        ; call the function under test
        ldx     t_x
        ldy     t_y
        lda     t_d
        jmp     _fn_put_digit
.endproc

.bss
t_x:    .res 1
t_y:    .res 1
t_d:    .res 1