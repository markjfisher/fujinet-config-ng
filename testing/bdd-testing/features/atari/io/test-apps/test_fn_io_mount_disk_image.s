        .import         pusha, _fn_io_mount_disk_image
        .export         _main, t_mode, t_slot
        .include        "fn_macros.inc"

.proc _main
        ; args:  slot, mode
        pusha   t_slot
        lda     t_mode

        jsr _fn_io_mount_disk_image
        rts
.endproc

.bss
t_mode:   .res 1
t_slot:   .res 1