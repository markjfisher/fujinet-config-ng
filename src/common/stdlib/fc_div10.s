        .export     _fc_div10

        .include    "zp.inc"
        .include    "macros.inc"

; extremely simple DIV 10 routine.
;
; INPUT
; A - number to divide by 10
; X - additional value to add to each part (e.g. convert to ascii add #'0')
; OUTPUT:
; quotient in A, remainder in X

.proc _fc_div10
        sta     tmp1
        stx     tmp2
        lda     #$00
        ldx     #$08
        asl     tmp1
l1:
        rol
        cmp     #10
        bcc     l2
        sbc     #10
l2:
        rol     tmp1
        dex
        bne     l1

        ; add any offset to remainder
        clc
        adc     tmp2
        tax             ; store the remainder in X

        lda     tmp1
        clc
        adc     tmp2

        rts
.endproc