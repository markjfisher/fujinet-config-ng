        .export     select_file
        .import     app_state
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_state.inc"

.proc select_file
        rts
.endproc
