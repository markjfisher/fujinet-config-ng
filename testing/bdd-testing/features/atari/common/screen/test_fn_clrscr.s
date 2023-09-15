        .export         _main
        .import         _clr_scr_all

        .include        "fc_zp.inc"
        .include        "fc_macros.inc"
        .include        "fn_data.inc"
        .include        "fn_io.inc"

.proc _main
        ; call the function under test
        jmp     _clr_scr_all
.endproc
