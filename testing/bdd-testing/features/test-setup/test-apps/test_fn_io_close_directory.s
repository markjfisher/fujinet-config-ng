        .import         _fn_io_close_directory
        .export         _main, t_host_slot
        .include        "fn_macros.inc"

.proc _main
        ; args:  host_slot
        lda     t_host_slot

        jsr _fn_io_close_directory
        rts
.endproc

.bss
t_host_slot:   .res 1