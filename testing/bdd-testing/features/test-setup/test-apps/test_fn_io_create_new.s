        .export         _main, t_host_slot, t_device_slot, t_size, t_path, t_newdisk
        .import         pusha, _fn_io_create_new, pushax
        .include        "fn_macros.inc"

.proc _main
        ; args: host_slot (uint8_t), device_slot (uint8_t), size (uint16_t)
        pusha   t_host_slot
        pusha   t_device_slot
        pushax  t_size
        pushax  t_newdisk
        setax   t_path

        jsr _fn_io_create_new
        rts
.endproc

.bss
t_host_slot:    .res 1
t_device_slot:  .res 1
t_size:         .res 2
t_newdisk:      .res 2
t_path:         .res 2
