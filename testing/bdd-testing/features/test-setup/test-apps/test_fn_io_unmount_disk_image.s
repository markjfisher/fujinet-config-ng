        .import         pusha, _fn_io_unmount_disk_image
        .export         _main, t_slot
        .include        "fn_macros.inc"

.proc _main
        ; args:  slot
        lda   t_slot

        jsr _fn_io_unmount_disk_image
        rts
.endproc

.bss
t_slot:   .res 1