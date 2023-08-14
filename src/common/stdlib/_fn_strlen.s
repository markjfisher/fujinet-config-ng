        .export     _fn_strlen
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; uint8 fn_strlen(char *p)
;
; returns string length (max 254) of string pointed at by p
; if no null was found, returns $ff as error
.proc _fn_strlen
        getax   ptr4        ; store p in ZP

        ldy     #$00
:       lda     (ptr4), y
        beq     out
        iny
        beq     err     ; rolled over to 0, exit with err
        bne     :-      ; always
err:
        lda #$ff
        ldx #$00
        rts
out:
        ldx     #$00
        tya
        rts
.endproc