        .export     _fn_put_help
        .import     getax, mhlp1
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; a/x point to internal-coded string, y = which help line (0, 1, 2, ...) - use zero base for ease
; Assumes all 40 bytes to be copied
.proc _fn_put_help
        sty     tmp1            ; which help line
        getax   ptr1            ; save char* s

        mwa     #mhlp1, ptr2
        ldx     tmp1
        beq     over

        ; add 40 per line - assumes help lines are continuous in memory (they are)
:       adw     ptr2, #40
        dex
        bne     :-

        ; loop over 40 chars
over:   ldy     #39
:       mva     {(ptr1), y}, {(ptr2), y}     ; copy directly to screen
        dey
        bpl     :-
        rts

.endproc
