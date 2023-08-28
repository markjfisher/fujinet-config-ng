        .export         _main, t_mode, t_host_slot, t_dev_slot, t_buff
        .import         pusha, _fn_io_set_device_filename
        .include        "fn_macros.inc"

.proc _main
        pusha   t_mode
        pusha   t_host_slot
        pusha   t_dev_slot
        setax   t_buff

        jsr _fn_io_set_device_filename
        rts
.endproc

.bss
t_buff:         .res 2
t_dev_slot:     .res 1
t_host_slot:    .res 1
t_mode:         .res 1
