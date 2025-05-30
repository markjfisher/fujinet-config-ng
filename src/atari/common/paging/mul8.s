.export     mul8

.include    "macros.inc"
.include    "zp.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; mul8
; multiply A by 8 into A/X. Destoys ptr4 (just 1 byte)
; --------------------------------------------------------------------
.proc mul8
        tax                     ; save the value we want to multiply while we setup high byte
        lda     #0
        sta     ptr4
        txa

        ; it's faster to rotate A (2 cycles), catch bits into high byte and finally have A as low byte
        ; than to shift zp (6 cycles each time)
        asl                     ; * 2
        rol     ptr4
        asl                     ; * 4
        rol     ptr4
        asl                     ; * 8
        rol     ptr4
        ; A = low byte already
        ldx     ptr4            ; high byte in X

        rts

; NOTES: I created a version that uses bcc/ora which was fewer cycles (15) when there are no bits to carry
; but was 35 bytes in length, and much less readable. It was 1 cycle longer only in the case when all 3 bits
; are set, so if we were optimising for speed, would be better.

.endproc 