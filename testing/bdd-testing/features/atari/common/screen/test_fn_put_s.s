        .export         _main, t_x, t_y, t_s
        .import         _put_s, pushax

        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "zeropage.inc"

.proc _main
        ; call the function under test
        pushax  #t_s
        ldx     t_x
        ldy     t_y
        jmp     _put_s
.endproc

.bss
t_x:    .res 1
t_y:    .res 1
t_s:    .res 64