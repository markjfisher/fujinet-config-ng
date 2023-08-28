        .export         _main, t_dev_slot, t_buffer
        .import         pusha, _fn_io_get_device_filename
        .include        "fn_macros.inc"

.proc _main
        pusha   t_dev_slot
        setax   t_buffer

        jsr _fn_io_get_device_filename
        rts
.endproc

.bss
t_dev_slot:     .res 1
t_buffer:       .res 2
