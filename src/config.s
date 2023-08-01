    .export     start
    .import     _main
    .import     __MAIN_START__, __MAIN_SIZE__

    .include    "zeropage.inc"
    .include    "inc/macros.inc"

.proc start
    ; mini crt0, setup real stack and software stack
    ldx     #$ff
    txs
    cld
    mwa     #(__MAIN_START__+__MAIN_SIZE__), sp

    jsr     _main
    rts

.endproc
