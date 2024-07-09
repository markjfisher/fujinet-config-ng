        .export     _fc_div10

        .include    "zp.inc"
        .include    "macros.inc"

; INPUT
; A - number to divide by 10
; X - additional value to add to each part (e.g. convert to ascii add #'0')
; OUTPUT:
; quotient in TMP1, remainder in A

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
        pha             ; push it until we do the quotient

        lda     tmp1
        clc
        adc     tmp2
        sta     tmp1
        pla

        rts
.endproc