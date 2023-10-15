        .export     _fc_atoi

        .import     mulax10

        .include    "zp.inc"
        .include    "macros.inc"

; uint16_t fc_atoi(char *s)
;
; extremely simplified atoi.
; convert string of number in range 1-65535 to word value, returned in A/X
; no care is taken to protect against overflowing
; no handling of negative numbers
; only handles base 10
.proc _fc_atoi
        axinto  ptr2        ; string
        ldy     #$00
        sty     tmp1
        sty     tmp2        ; result in tmp1/2

dig_loop:
        lda     (ptr2), y   ; next char
        beq     out
        sec
        sbc     #'0'        ; convert to digit
        sta     tmp3        ; store in tmp3
        cpy     #$00
        beq     :+          ; don't multiply the first time around, this is just 0 * 10
        setax   tmp1        ; load result
        jsr     mulax10
        axinto  tmp1
        lda     tmp3
        beq     over
:       adw1    tmp1, a     ; tmp1/2 += next digit
over:
        iny
        bne     dig_loop    ; exit will be nul char

out:    setax   tmp1        ; get result into a/x (x already set to tmp2)
        rts
.endproc