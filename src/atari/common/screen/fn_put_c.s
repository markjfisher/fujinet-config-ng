        .export     fn_put_c

        .import     fn_get_scrloc, ascii_to_code

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void fn_put_c(c, x, y)
;
; INTERNAL FUNCTION: called with A=ascii char, X=x, Y=y.
; DOES NOT USE STACK PARAMS to reduce cycles.
;
; print a char at the screen location x, y accounting for 2x2 border
; x and y are in 36x16 grid, so can assume under these values (i.e. bmi ok)
; no protection against x,y or the char to process being bad.
.proc fn_put_c
        pha                     ; save the char
        jsr     fn_get_scrloc  ; use X,Y to get screen location in ptr4
        pla
        jsr     ascii_to_code
        ldy     #$00
        sta     (ptr4), y
        rts
.endproc
