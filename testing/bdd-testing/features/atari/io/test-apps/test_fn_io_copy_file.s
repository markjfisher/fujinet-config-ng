        .import         pusha, _fn_io_copy_file
        .export         _main, t_src, t_dst
        .include        "fn_macros.inc"

.proc _main
        ; args: host_slot (uint8), device_slot (uint8), size (uint16)
        pusha   t_src
        lda     t_dst

        jsr _fn_io_copy_file
        rts
.endproc

.bss
t_src:    .res 1
t_dst:    .res 1
