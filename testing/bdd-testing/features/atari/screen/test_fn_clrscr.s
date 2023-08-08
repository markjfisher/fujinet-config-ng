        .export         _main
        .import         _fn_clrscr

        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "zeropage.inc"

.proc _main
        ; call the function under test
        jmp     _fn_clrscr
.endproc
