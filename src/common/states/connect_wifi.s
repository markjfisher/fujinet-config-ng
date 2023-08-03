        .export     connect_wifi
        .import     app_state
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_state.inc"

.proc connect_wifi
        rts
.endproc
