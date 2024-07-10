        .export     _put_s
        .export     _put_s_fast

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
; Use the macro put_s to get setup for variables.
;
; print string at the screen location x, y accounting for boundaries
; x and y are in small inner grid (about 38x22), so can assume under these values (i.e. bmi ok)

_put_s:
        ; load and check x,y boundary
        ; couldn't do this with inscsp1 and skipping load of x, because popa trashes y reg. ends up being more memory anyway
        cpx     #SCR_WID_NB
        bcs     put_s_exit
        cpy     #SCR_HEIGHT
        bcs     put_s_exit

        jsr     get_scrloc      ; use X,Y to get screen location in ptr4

_put_s_fast:
        ; print characters from s in tmp9, 1 by 1 until hit a 0, or hit x=SCR_WID_NB in boundary
        ldy     #$00            ; the n'th character

@next_char:
        lda     (tmp9), y       ; char to print in A
        beq     put_s_exit            ; end of string

        jsr     ascii_to_code
        sta     (ptr4), y       ; print char

        inx
        cpx     #SCR_WID_NB
        bcs     put_s_exit            ; out of bounds in X
        iny                     ; move across a character, used for string and screen loc
        bcc     @next_char

put_s_exit:
        rts

