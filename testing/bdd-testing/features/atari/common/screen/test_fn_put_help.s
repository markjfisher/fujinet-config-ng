        .export         _main, t_y, t_s
        .import         _put_help, pusha

        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "zeropage.inc"

.proc _main
        ; call the function under test
        pusha   t_y
        setax   #t_s
        jmp     _put_help
.endproc

.bss
t_y:    .res 1
t_s:    .res 64