        .export     _fc_strncpy
        .import     popax, popa

        .include    "fc_macros.inc"
        .include    "fc_zp.inc"

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

; void fc_strncpy(char *dst, char *src, uint8_t count)
;
; THIS FUNCTION TRASHES tmp6-10
.proc   _fc_strncpy
        sta     tmp6    ; count
        popax   tmp7    ; src : 13/14
        popax   tmp9    ; dst : 15/16

        ldy     #$00
:       mva     {(tmp7), y}, {(tmp9), y}
        beq     fill_zeroes ; hit end of string
        iny
        cpy     tmp6
        bne :-
        beq     out

fill_zeroes:
        ; fill to count with 0
        lda     #$00
:       iny
        cpy     tmp6
        beq     out
        sta     (tmp9), y
        bne :-

out:    rts
.endproc
