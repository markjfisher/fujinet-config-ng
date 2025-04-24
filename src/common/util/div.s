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
