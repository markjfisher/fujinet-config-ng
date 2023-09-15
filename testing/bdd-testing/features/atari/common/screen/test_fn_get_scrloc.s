        .export         _main, t_x, t_y
        .import         get_scrloc

        .include        "fc_macros.inc"
        .include        "fn_io.inc"
        .include        "fc_zp.inc"

.proc _main
        ; call the function under test
        ldx     t_x
        ldy     t_y
        jmp     get_scrloc
.endproc

.bss
t_x:    .res 1
t_y:    .res 1