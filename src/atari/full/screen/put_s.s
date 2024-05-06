        .export     _put_s

        .import     ascii_to_code
        .import     get_scrloc
        .import     popa

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

; expects:
;   tmp9 = pointer to string
;   tmp8 = x
;   tmp7 = y
;
; print string at the screen location x, y accounting for boundaries
; x and y are in small inner grid (about 38x22), so can assume under these values (i.e. bmi ok)

.proc _put_s
        ; load and check x,y boundary
        ; couldn't do this with inscsp1 and skipping load of x, because popa trashes y reg. ends up being more memory anyway
        ldx     tmp8
        cpx     #SCR_WID_NB
        bcs     exit
        ldy     tmp7
        cpy     #SCR_HEIGHT
        bcs     exit

:       jsr     get_scrloc      ; use X,Y to get screen location in ptr4

do_string:
        ; print characters from s in tmp9, 1 by 1 until hit a 0, or hit x=36 in boundary
        ldy     #$00            ; the n'th character

next_char:
        lda     (tmp9), y       ; char to print in A
        beq     exit            ; end of string

        jsr     ascii_to_code
        sta     (ptr4), y       ; print char

        inc     tmp8            ; x+1, small numbers so no need to check C
        lda     tmp8
        cmp     #SCR_WID_NB
        bcs     exit            ; out of bounds in X
        iny                     ; move across a character, used for string and screen loc
        bcc     next_char

exit:
        rts
.endproc

