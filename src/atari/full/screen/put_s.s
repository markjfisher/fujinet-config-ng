        .export     _put_s
        .export     _put_s_direct
        .export     _put_s_nl

        .import     ascii_to_code
        .import     get_scrloc

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
        stx     put_s_store_x   ; save X in case we use the fast prints later
        cpx     #SCR_WID_NB
        bcs     put_s_exit
        cpy     #SCR_HEIGHT
        bcs     put_s_exit

        jsr     get_scrloc      ; use X,Y to get screen location in ptr4

_put_s_direct:
        ; print characters from s in tmp9, 1 by 1 until hit a 0, or hit x=SCR_WID_NB in boundary
        ldy     #$00            ; the n'th character

put_s_next_char:
        lda     (tmp9), y       ; char to print in A
        beq     put_s_exit            ; end of string

        jsr     ascii_to_code
        sta     (ptr4), y       ; print char

        inx
        cpx     #SCR_WID_NB
        bcs     put_s_exit            ; out of bounds in X
        iny                     ; move across a character, used for string and screen loc
        bcc     put_s_next_char

put_s_exit:
        rts

; put the string pointed to by ptr9 directly below current position without bounds checks.
; hacky but fast
_put_s_nl:
        adw1    ptr4, #SCR_WIDTH
        ; x is incremented during the print, but we need it to go back to where previous string started so bounds check is correct
        ldx     put_s_store_x
        bne     _put_s_direct

.bss
put_s_store_x:  .res 1
