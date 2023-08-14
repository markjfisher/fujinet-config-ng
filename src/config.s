    .export     start
    .import     _main
    .import     __MAIN_START__, __MAIN_SIZE__, _fn_memclr_page, setax

    .include    "zeropage.inc"
    .include    "fn_macros.inc"

.proc start
    ; mini crt0, setup real stack and software stack
    ldx     #$ff
    txs
    cld
    mwa     #(__MAIN_START__+__MAIN_SIZE__), sp

    ; clear 256 bytes from SP, not really required, but useful to ensure no data is in stack
    setax   sp
    jsr     _fn_memclr_page

    ; GO!
    jmp     _main

.endproc
