        .export     put_char
        .import     get_scrloc
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void put_char(c, x, y)
;
; INTERNAL FUNCTION: called with A=ascii char, X=x, Y=y.
; DOES NOT USE STACK PARAMS to reduce cycles.
;
; print a char at the screen location x, y accounting for boundaries
; x and y are in 36x16 grid, so can assume under these values (i.e. bmi ok)
; no protection against x,y or the char to process being bad.
.proc put_char
        pha                     ; save the char
        jsr     get_scrloc      ; use X,Y to get screen location in ptr4
        pla

        ; from cc65/libsrc/atari/cputc.s
        asl     a               ; shift out the inverse bit
        adc     #$c0            ; grab the inverse bit; convert ATASCII to screen code
        bpl     codeok          ; screen code ok?
        eor     #$40            ; needs correction
codeok: lsr     a               ; undo the shift
        bcc     :+
        eor     #$80            ; restore the inverse bit

:       ldy     #$00
        sta     (ptr4), y

        rts
.endproc
