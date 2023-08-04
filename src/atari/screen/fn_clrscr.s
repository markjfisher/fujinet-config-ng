        .export     _fn_clrscr
        .import     get_scrloc
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; clears the internal screen of our 36x16 display
.proc _fn_clrscr
        ldx     #$00
        ldy     #$00
        jsr     get_scrloc

        ldx     #15     ; rows-1
ycol:   ldy     #35     ; cols-1, yeah, we need Y as the index for x col...
xrow:   lda     #$00    ; screen code for ' '
        sta     (ptr4), y
        dey
        bpl     xrow
        adw     ptr4, #40
        dex
        bpl     ycol
        rts
.endproc
