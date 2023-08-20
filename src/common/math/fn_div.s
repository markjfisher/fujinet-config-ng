        .export     fn_div

        .include    "zeropage.inc"

; simple 8 bit div, from http://6502org.wikidot.com/software-math-intdiv
;
; tmp1 = quotient
; tmp2 = divisor
; on return
; tmp1 = q/d
; tmp2 = remainder
.proc fn_div
        lda     #$00
        ldx     #$08
        asl     tmp1    ; q
L1:     rol
        cmp     tmp2    ; b
        bcc     L2
        sbc     tmp2    ; b
L2:     rol     tmp1    ; q
        dex
        bne     L1
        rts
.endproc
