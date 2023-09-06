        .export     _put_s

        .import     ascii_to_code
        .import     get_scrloc
        .import     popa

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; void put_s(uint8_t X, uint8_t Y, char *s)
; X, Y contain coordinates for string
; char *S is on call stack
;
; print a char at the screen location x, y accounting for boundaries
; x and y are in 36x16 grid, so can assume under these values (i.e. bmi ok)
.proc _put_s
        axinto  ptr3            ; char *s
        popa    tmp2            ; y
        popa    tmp1            ; x

        ; load and check x,y boundary
        ldx     tmp1
        cpx     #SCR_WIDTH-2
        bcs     exit
        ldy     tmp2
        cpy     #20
        bcs     exit

        jsr     get_scrloc   ; use X,Y to get screen location in ptr4

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
        cmp     #SCR_WIDTH-2
        bcs     exit            ; out of bounds in X
        iny                     ; move across a character, used for string and screen loc
        bcc     next_char

exit:
        rts
.endproc

