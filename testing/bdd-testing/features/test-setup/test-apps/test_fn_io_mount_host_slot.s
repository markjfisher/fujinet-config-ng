        .export         _main, t_slot, t_hostslots
        .import         pusha, _fn_io_mount_host_slot
        .include        "fn_macros.inc"

.proc _main
        pusha   t_slot
        setax   #t_hostslots

        jsr _fn_io_mount_host_slot
        rts
.endproc

.bss
t_slot:         .res 1
t_hostslots:    .res 96         ; we only test 3 slots
