        .export     _fn_clrscr, _fn_clr_help, _fn_clr_status
        .import     fn_get_scrloc
        .import     mhlp1, sline1
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; clears the internal screen of our 36x16 display, and the help and status texts
.proc _fn_clrscr
        ldx     #$00
        ldy     #$00
        jsr     fn_get_scrloc

        ldx     #15     ; rows-1
ycol:   ldy     #35     ; cols-1, yeah, we need Y as the index for x col...
xrow:   lda     #$00    ; screen code for ' '
        sta     (ptr4), y
        dey
        bpl     xrow
        adw     ptr4, #40
        dex
        bpl     ycol

        jsr     _fn_clr_status
        jmp     _fn_clr_help
.endproc

.proc _fn_clr_help
        ; clear help texts. 4 lines of 40 bytes
        mwa     #mhlp1, ptr4
        ldx     #160
        jmp     do_clear
.endproc

.proc _fn_clr_status
        ; clear the status lines. 3 lines of 40 bytes
        mwa     #sline1, ptr4
        ldx     #120
        jmp     do_clear
.endproc

.proc do_clear
        ldy     #$00
        lda     #FNC_FULL       ; inverse space
:       sta     (ptr4), y
        iny
        dex
        bne     :-
        rts
.endproc
