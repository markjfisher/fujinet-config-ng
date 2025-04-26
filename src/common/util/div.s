        .export     _div_i16_by_i8

        .import     popa

        .include    "zp.inc"
        .include    "macros.inc"

; uint16_t div_i16_by_i8(uint8_t denominator, uint16_t numerator)
;
; adapted from http://6502org.wikidot.com/software-math-intdiv
; simple 16 bit division by 8 bit number
; returns quotient in A (low), remainder in X (high), which if called by C will need separating from result

_div_i16_by_i8:
        sta     tmp1    ; low byte of 16 bit numerator   (TLQ)
        stx     tmp2    ; high byte of 16 bit numberator (TH)
        popa    tmp3    ; denominator                    (B)

        cmp     #$10    ; do simple shifts for /16
        beq     fast_div16

        lda     tmp2    ; high
        ldx     #$08
        asl     tmp1

@l1:    rol     a
        bcs     @l2
        cmp     tmp3
        bcc     @l3

@l2:    sbc     tmp3

        ; SEC is needed when the BCS L2 branch above was taken
        sec
@l3:    rol     tmp1
        dex
        bne     @l1

        ; now we have A with remainder, and TLQ/tmp1 with the quotient
        tax             ; move remainder into X
        lda     tmp1    ; get quotient into A
        rts

; page caching is exactly 16 in page_size, so we need to div16, and so we can optimize that scenario
fast_div16:
        lda     #$00
        sta     tmp3    ; remainder

; rotoate 4 bits tmp2->tmp1->tmp3, which leaves:
; tmp2|tmp1 => divided by 16
; tmp3      => remainder
        lsr     tmp2
        ror     tmp1
        ror     tmp3

        lsr     tmp2
        ror     tmp1
        ror     tmp3

        lsr     tmp2
        ror     tmp1
        ror     tmp3

        lsr     tmp2
        ror     tmp1
        ror     tmp3

        ; move tmp3 across 4 times to get remainder from high nybble to low one
        lda     tmp3
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        tax                     ; remainder
        lda     tmp1            ; quotient
        rts
