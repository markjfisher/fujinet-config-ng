        .import         _fn_io_set_boot_mode
        .export         _main, t_mode
        .include        "../../../../../src/inc/macros.inc"

.proc _main
        ; args:  mode (uint8)
        lda     t_mode

        jsr     _fn_io_set_boot_mode
        rts
.endproc

.bss
t_mode:   .res 1