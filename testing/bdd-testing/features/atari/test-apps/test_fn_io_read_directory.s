        .import         pusha, _fn_io_read_directory
        .export         _main, t_maxlen, t_aux2
        .include        "../../../../../src/inc/macros.inc"

.proc _main
        ; args:  maxlen, aux2
        pusha   t_maxlen
        lda     t_aux2

        jsr _fn_io_read_directory
        rts
.endproc

.bss
t_maxlen:   .res 1
t_aux2:     .res 1
