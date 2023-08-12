        .export     _fn_memclr_page, _fn_memclr

        .import     popa

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void fn_memclr_page(void *p)
.proc _fn_memclr_page
    getax   ptr4

    ldy     #$00
    lda     #$00
:   sta     (ptr4), y
    iny
    bne     :-

    rts
.endproc

; void fn_memclr(uint8 count)
.proc _fn_memclr
    getax   ptr4
    popa    tmp4
    cmp     #$00
    beq     no_copy

    ldy     #$00
    lda     #$00
:   sta     (ptr4), y
    iny
    cpy     tmp4
    bne     :-

no_copy:
    rts
.endproc