        .export         _main
        .import         _fn_clrscr

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_data.inc"
        .include        "fn_io.inc"

.proc _main
        ; call the function under test
        jmp     _fn_clrscr
.endproc
