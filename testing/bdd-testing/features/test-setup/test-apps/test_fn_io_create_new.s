        .import         pusha, _fn_io_create_new
        .export         _main, t_host_slot, t_device_slot, t_size
        .include        "fn_macros.inc"

.proc _main
        ; args: host_slot (uint8), device_slot (uint8), size (uint16)
        pusha   t_host_slot
        pusha   t_device_slot
        setax   t_size

        jsr _fn_io_create_new
        rts
.endproc

.bss
t_host_slot:    .res 1
t_device_slot:  .res 1
t_size:         .res 2
