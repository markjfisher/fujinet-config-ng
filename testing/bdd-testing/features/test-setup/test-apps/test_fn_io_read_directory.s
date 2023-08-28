        .export         _main, t_maxlen, t_aux2, t_buffer
        .import         pusha, _fn_io_read_directory
        .include        "fn_macros.inc"

.proc _main
        pusha   t_maxlen
        pusha   t_aux2
        setax   t_buffer

        jsr _fn_io_read_directory
        rts
.endproc

.bss
t_maxlen:   .res 1
t_aux2:     .res 1
t_buffer:   .res 2