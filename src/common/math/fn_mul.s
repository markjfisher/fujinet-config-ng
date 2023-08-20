        .export     fn_mul

        .include    "zeropage.inc"

; simple 8 bit mul from https://llx.com/Neil/a2/mult.html
;
; num1 = tmp1
; num2 = tmp2
; result = tmp3, tmp4
.proc fn_mul
        LDA     #$80     ; Preload sentinel bit into RESULT
        STA     tmp3
        ASL     A        ; Initialize RESULT hi byte to 0
	    DEC     tmp1
L1:     LSR     tmp2     ; Get low bit of NUM2
        BCC     L2       ; 0 or 1?
        ADC     tmp1     ; If 1, add (NUM1-1)+1
L2:     ROR     A        ; "Stairstep" shift (catching carry from add)
        ROR     tmp3
        BCC     L1       ; When sentinel falls off into carry, we're done
        STA     tmp4
        rts
.endproc
