        .export     _fn_put_digit
        .import     _fn_get_scrloc
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void _fn_put_digit(d, x, y)
;
; INTERNAL FUNCTION: called with A=digit, X=x, Y=y.
; DOES NOT USE STACK PARAMS to reduce cycles.
;
; print a digit at the screen location x, y accounting for boundaries
; x and y are in 36x16 grid, so can assume under these values (i.e. bmi ok)
; no protection against x,y or the digit to process.
.proc _fn_put_digit
        pha                     ; save the digit
        jsr     _fn_get_scrloc  ; use X,Y to get screen location in ptr4

        pla
        adc     #$10            ; screen code for digit is $10 + digit
        ldy     #$00
        sta     (ptr4), y

        rts
.endproc
