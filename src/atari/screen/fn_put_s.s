        .export     _fn_put_s
        .import     get_scrloc, popax
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void _fn_put_s(char *s, X, Y)
; X, Y contain coordinates for string
; S is on call stack
;
; print a char at the screen location x, y accounting for boundaries
; x and y are in 36x16 grid, so can assume under these values (i.e. bmi ok)
; no protection against x,y or the char to process being bad.
.proc _fn_put_s
        stx     tmp1            ; save x
        sty     tmp2            ; save y
        popax   ptr1            ; save char* s

        ; check x,y boundary, can't do this before popax
        ldx     tmp1
        cpx     #36
        bcs     exit
        ldy     tmp2
        cpy     #16
        bcs     exit

        jsr     get_scrloc      ; use X,Y to get screen location in ptr4

do_string:
        ; print characters from s in ptr1, 1 by 1 until hit a 0, or hit x=36 in boundary
        ldy     #$00            ; the n'th character

next_char:
        lda     (ptr1), y       ; char to print in A
        beq     exit            ; end of string

        ; for known strings, we just encode them internally instead of converting to avoid translating
        ; this is only really needed for externally sourced strings
        ; ---------------------------------
        ; ascii char to screen code from cc65/libsrc/atari/cputc.s
        asl     a               ; shift out the inverse bit
        adc     #$c0            ; grab the inverse bit; convert ATASCII to screen code
        bpl     codeok          ; screen code ok?
        eor     #$40            ; needs correction
codeok: lsr     a               ; undo the shift
        bcc     :+
        eor     #$80            ; restore the inverse bit
        ; ---------------------------------
:       sta     (ptr4), y       ; print char

        inc     tmp1            ; x+1, small numbers so no need to check C
        lda     tmp1
        cmp     #36
        bcs     exit            ; out of bounds in X
        iny                     ; move across a character, used for string and screen loc
        bcc     next_char

exit:
        rts
.endproc
