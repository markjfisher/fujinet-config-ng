        .export     strncat
        .import     popax, popa
        .importzp   tmp1, ptr1, ptr2
        .include    "../inc/macros.inc"

; int strncat(char *dst, char *src, int n)
;
; The strncat function appends not more than n characters of the string
; pointed to by t2 to the end of the string pointed to by t1. The terminating
; null character at the end of s1 is overwritten. A terminating null character
; is appended to the result, even if not all of s2 is appended to s1.
;
; returns a = 0 if no error, 1 otherwise (didn't find nul in dst) 

.proc strncat
        sta   tmp1      ; n
        popax ptr2      ; src
        popax ptr1      ; dst

        ldy #$00
:       lda (ptr1), y
        beq found
        iny

        beq error       ; rolled around and didn't find a 0 in string
        bne :-

found:
        ady ptr1

        ; copy the string to location found
        ; can only copy n chars max, including a nul
        ; subtract 1 from n, as we will only copy 1 less chars if possible
        dec tmp1

        ldy #0
:       mva {(ptr2),y}, {(ptr1),y}
        beq out             ; we copied a nul before n reached, we can end now
        iny
        cpy tmp1
        bne :-              ; haven't reached n yet

        ; add the nul, as we didn't encounter one, but reached max
        mva #$00, {(ptr1),y}
out:
        lda #$00
        rts

error:
        lda #$01
        rts

.endproc
