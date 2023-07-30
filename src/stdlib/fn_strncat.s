        .export     _fn_strncat
        .import     popax
        .include    "zeropage.inc"
        .include    "../inc/macros.inc"

; int _fn_strncat(char *dst, char *src, uint8 n)
;
; A cut down version of strncat that works for strings up to 256 bytes.
; This requires a nul terminating (0) byte in the dst string to start appending from.
;
; The _fn_strncat function appends not more than n characters of the string
; pointed to by src to the end of the string pointed to by dst. The terminating
; null character at the end of dst is overwritten. A terminating null character
; is appended to the result, even if not all of src is appended to dst.
;
; returns a = 0 if no error, 1 otherwise (didn't find terminating byte in dst)

.proc _fn_strncat
        sta     tmp1      ; n
        popax   ptr2      ; src
        popax   ptr1      ; dst

        ldy     #$00
:       lda     (ptr1), y
        beq     found
        iny

        beq     error       ; rolled around and didn't find a 0 in string
        bne :-

found:
        ; add y to ptr1
        tya
        clc
        adc     ptr1
        sta     ptr1
        bcc :+
        inc     ptr1+1
:

        ; copy the string to location found
        ; can only copy n chars max, including a nul
        ; subtract 1 from n, as we will only copy 1 less chars if possible
        dec     tmp1

        ldy     #$00
:       mva     {(ptr2),y}, {(ptr1),y}
        beq     out             ; we copied a nul before n reached, we can end now
        iny
        cpy     tmp1
        bne :-              ; haven't reached n yet

        ; add the nul, as we didn't encounter one, but reached max
        mva     #$00, {(ptr1),y}
out:
        ldx     #$00
        lda     #$00
        rts

error:
        ldx     #$00
        lda     #$01
        rts

.endproc
