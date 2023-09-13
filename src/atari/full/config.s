    .export     start
    .import     _main
    .import     __STACK_START__, __STACK_SIZE__
    .import     initlib
    .import     zerobss

    .include    "fc_zp.inc"
    .include    "fn_macros.inc"

.proc start
    ; mini crt0, setup real stack and software stack
    ; NOTE: config is not expected currently to survive loading as a conventional app, as it usually cold-starts another disk.
    ; else more work needs doing here to save the old stack pointer, and things like LMARGN etc.
    ldx     #$ff
    txs
    cld
    ; Stack works DOWNWARDS! So need to add the stack size here
    mwa     {#(__STACK_START__ + __STACK_SIZE__)}, sp

    ; initialise BSS to be nice and clear 
    jsr     zerobss

    ; call library initialisers - only have malloc installed. sets up heap for malloc.
    jsr     initlib

    ; GO!
    jmp     _main

.endproc
