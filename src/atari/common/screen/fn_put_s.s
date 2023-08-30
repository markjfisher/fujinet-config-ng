        .export     _fn_put_s, ascii_to_code

        .import     fn_get_scrloc, popa

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void fn_put_s(uint8_t X, uint8_t Y, char *s)
; X, Y contain coordinates for string
; char *S is on call stack
;
; print a char at the screen location x, y accounting for boundaries
; x and y are in 36x16 grid, so can assume under these values (i.e. bmi ok)
.proc _fn_put_s
        axinto  ptr3            ; char *s
        popa    tmp2            ; y
        popa    tmp1            ; x

        ; load and check x,y boundary
        ldx     tmp1
        cpx     #36
        bcs     exit
        ldy     tmp2
        cpy     #20
        bcs     exit

        jsr     fn_get_scrloc   ; use X,Y to get screen location in ptr4

do_string:
        ; print characters from s in ptr3, 1 by 1 until hit a 0, or hit x=36 in boundary
        ldy     #$00            ; the n'th character

next_char:
        lda     (ptr3), y       ; char to print in A
        beq     exit            ; end of string

        jsr     ascii_to_code
        sta     (ptr4), y       ; print char

        inc     tmp1            ; x+1, small numbers so no need to check C
        lda     tmp1
        cmp     #36
        bcs     exit            ; out of bounds in X
        iny                     ; move across a character, used for string and screen loc
        bcc     next_char

exit:
        rts
.endproc

; common routine to convert ascii code in A into internal code for screen
; from cc65/libsrc/atari/cputc.s
.proc   ascii_to_code
        asl     a               ; shift out the inverse bit
        adc     #$c0            ; grab the inverse bit; convert ATASCII to screen code
        bpl     codeok          ; screen code ok?
        eor     #$40            ; needs correction
codeok: lsr     a               ; undo the shift
        bcc     :+
        eor     #$80            ; restore the inverse bit
:       rts
.endproc
