        .export     destination_host_slot
        .import     app_state
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_state.inc"

.proc destination_host_slot
        rts
.endproc
