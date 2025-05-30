.export     mul8

.include    "macros.inc"
.include    "zp.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; mul8
; multiply A by 8 into A/X. Destoys tmp10
; --------------------------------------------------------------------
.proc mul8
        tax                     ; save the value we want to multiply while we setup high byte
        lda     #$00
        sta     tmp10
        txa

        ; it's faster to rotate A (2 cycles), catch bits into high byte and finally have A as low byte
        ; than to shift zp (6 cycles each time)
        asl                     ; * 2
        rol     tmp10
        asl                     ; * 4
        rol     tmp10
        asl                     ; * 8
        rol     tmp10
        ; A = low byte already
        ldx     tmp10            ; high byte in X

        rts

; NOTES: I created a version that uses bcc/ora which was fewer cycles (15) when there are no bits to carry
; but was 35 bytes in length, and much less readable. It was 1 cycle longer only in the case when all 3 bits
; are set, so if we were optimising for speed, would be better.

.endproc 