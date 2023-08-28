        .export         _main, t_src, t_dst, t_spec
        .import         pusha, _fn_io_copy_file
        .include        "fn_macros.inc"

.proc _main
        pusha   t_src
        pusha   t_dst
        setax   t_spec

        jsr _fn_io_copy_file
        rts
.endproc

.bss
t_src:    .res 1
t_dst:    .res 1
t_spec:   .res 2
