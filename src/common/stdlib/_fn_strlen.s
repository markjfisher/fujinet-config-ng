        .export     _fn_strlen
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; uint8 fn_strlen(char *p)
;
; returns string length (max 255) of string pointed at by p
; if no null was found, returns 0
.proc _fn_strlen
        getax   ptr4        ; store p in ZP

        ldy     #$00
:       lda     (ptr4), y
        beq     out
        iny
        beq     out     ; rolled over to 0, exit
        bne     :-      ; always

out:
        ldx     #$00
        tya
        rts
.endproc