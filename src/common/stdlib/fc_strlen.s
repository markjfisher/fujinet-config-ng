        .export     _fc_strlen
        .include    "zp.inc"
        .include    "macros.inc"

; uint8_t fc_strlen(char *p)
;
; returns string length (max 254) of string pointed at by p
; if no null was found, returns $ff as error
; uses tmp9/10
.proc _fc_strlen
        axinto  tmp9    ; p
        ldx     #$00

        ldy     #$00
:       lda     (tmp9), y
        beq     out
        iny
        beq     err     ; rolled over to 0, exit with err
        bne     :-      ; always
err:
        lda     #$ff
        rts
out:
        tya
        rts
.endproc