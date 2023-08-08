        .export         _main, t_y, t_s
        .import         _fn_put_help, setax

        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "zeropage.inc"

.proc _main
        ; call the function under test
        setax   #t_s
        ldy     t_y
        jmp     _fn_put_help
.endproc

.bss
t_y:    .res 1
t_s:    .res 64