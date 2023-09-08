        .export     put_s_p1p4
        .import     ascii_to_code

        .include    "zeropage.inc"

; Internal simple print to screen function using ptr1/4
;
; write the string at ptr1 to screen location (ptr4)
; no bounds checking. copies until finds 0
.proc put_s_p1p4
        ldy     #$00
:       lda     (ptr1), y
        beq     :+

        jsr     ascii_to_code
        sta     (ptr4), y
        iny
        bne     :-
:
        rts
.endproc