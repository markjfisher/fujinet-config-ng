; strncpy.s
;
; From various docs:
; Copies the first n characters of source to destination. If the end of the
; source C string (which is signaled by a null-character) is found before num
; characters have been copied, destination is padded with zeros until a total
; of n characters have been written to it.

; No null-character is implicitly appended at the end of destination if source
; is longer than n. Thus, in this case, destination shall not be considered a
; null terminated C string (reading it as such would overflow).

        .export     strncpy
        .import     popax, popa
        .include    "../inc/macros.inc"
        .include    "zeropage.inc"

; void strcat(char *dst, char *src, int count)
.proc   strncpy
        sta   tmp1
        popax ptr2
        popax ptr1

        ldy #0
:       mva {(ptr2), y}, {(ptr1), y}
        beq fill_zeroes ; hit end of string
        iny
        cpy tmp1
        bne :-
        beq out

fill_zeroes:
        ; fill to count with 0
        lda #$00
:       iny
        cpy tmp1
        beq out
        sta (ptr1), y
        bne :-

out:    rts
.endproc
