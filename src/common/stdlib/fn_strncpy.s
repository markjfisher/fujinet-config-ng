        .export     _fn_strncpy
        .import     popax, popa
        .include    "fn_macros.inc"
        .include    "zeropage.inc"

; This is a cutdown version of strncpy for use on strings up to 256 characters.
;
; From various docs:
; Copies the first n characters of source to destination. If the end of the
; source C string (which is signaled by a null-character) is found before num
; characters have been copied, destination is padded with zeros until a total
; of n characters have been written to it.

; No null-character is implicitly appended at the end of destination if source
; is longer than n. Thus, in this case, destination shall not be considered a
; null terminated C string (reading it as such would overflow).

; void strcat(char *dst, char *src, uint8_t count)
;
; THIS FUNCTION TRASHES tmp4, ptr3, ptr4
.proc   _fn_strncpy
        sta     tmp4
        popax   ptr4
        popax   ptr3

        ldy     #$00
:       mva     {(ptr4), y}, {(ptr3), y}
        beq     fill_zeroes ; hit end of string
        iny
        cpy     tmp4
        bne :-
        beq     out

fill_zeroes:
        ; fill to count with 0
        lda     #$00
:       iny
        cpy     tmp4
        beq     out
        sta     (ptr3), y
        bne :-

out:    rts
.endproc
