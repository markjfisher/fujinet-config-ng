        .import         _fn_io_set_directory_position
        .export         _main, t_pos
        .include        "fn_macros.inc"

.proc _main
        ; args:  pos (int)
        setax   t_pos

        jsr _fn_io_set_directory_position
        rts
.endproc

.bss
t_pos:   .res 2