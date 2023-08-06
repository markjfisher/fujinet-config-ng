    .export     start
    .import     _main
    .import     __MAIN_START__, __MAIN_SIZE__

    .include    "zeropage.inc"
    .include    "fn_macros.inc"

.proc start
    ; mini crt0, setup real stack and software stack
    ldx     #$ff
    txs
    cld
    mwa     #(__MAIN_START__+__MAIN_SIZE__), sp

    ; clear 256 bytes from SP - simple routine, we currently only need 1 page of Stack.
    ldy     #$00
    lda     #$00
:   sta     (sp), y
    iny
    bne     :-
    
    jmp     _main

.endproc
