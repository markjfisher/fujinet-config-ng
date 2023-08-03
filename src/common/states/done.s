        .export     done
        .import     app_state
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_state.inc"

.proc done
        rts
.endproc
