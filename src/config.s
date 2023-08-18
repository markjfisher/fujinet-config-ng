    .export     start
    .import     _main
    .import     __STACK_START__, __STACK_SIZE__
    .import     _fn_memclr_page
    .import     setax

    .include    "zeropage.inc"
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

    ; clear 256 bytes from SP, not really required, but useful to ensure no data is in stack
    setax   sp
    jsr     _fn_memclr_page

    ; GO!
    jmp     _main

.endproc
