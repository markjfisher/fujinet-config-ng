        .export         _main, t_host_slot, t_buffer
        .import         pusha, _fn_io_open_directory
        .include        "fn_macros.inc"

.proc _main
        pusha   t_host_slot
        setax   t_buffer

        jsr _fn_io_open_directory
        rts
.endproc

.bss
t_host_slot:    .res 1
t_buffer:       .res 2
