        .export         _main, t_x, t_y
        .import         _fn_get_scrloc

        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "zeropage.inc"

.proc _main
        ; call the function under test
        ldx     t_x
        ldy     t_y
        jmp     _fn_get_scrloc
.endproc

.bss
t_x:    .res 1
t_y:    .res 1