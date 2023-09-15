        .export         _main, t_y, t_s
        .import         _put_help, pusha

        .include        "fc_macros.inc"
        .include        "fn_io.inc"
        .include        "fc_zp.inc"

.proc _main
        ; call the function under test
        pusha   t_y
        pusha   #0
        setax   #t_s
        jmp     _put_help
.endproc

.bss
t_y:    .res 1
t_s:    .res 64