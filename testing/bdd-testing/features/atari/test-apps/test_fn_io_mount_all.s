        .import         _fn_io_mount_all
        .export         _main
        .include        "../../../../../src/inc/fn_macros.inc"

.proc _main
        jsr _fn_io_mount_all
        rts
.endproc
