        .export     _fn_clrscr, _fn_clr_help, _fn_clr_status, clear_box1, clear_box2
        .import     fn_get_scrloc
        .import     mhlp1, sline1
        .import     debug
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; clears the internal screen of our 36x16 display, and the help and status texts
.proc _fn_clrscr
        jsr     clear_box1

        ldx     #0              ; top of middle line
        mva     #$55, tmp1
        jsr     clear_next_x

        ldx     #0              ; middle bar
        mva     #$80, tmp1
        jsr     clear_next_x

        ldx     #0              ; bottom of middle bar
        mva     #$d5, tmp1
        jsr     clear_next_x

        ldx     #10             ; bottom 10 rows
        mva     #$00, tmp1
        jsr     clear_next_x

        jsr     _fn_clr_status
        jmp     _fn_clr_help
        ; implicit rts

.endproc

; clear next X lines with tmp1 char
.proc clear_next_x
ycol:   ldy     #35     ; cols-1, yeah, we need Y as the index for x col...
xrow:   lda     tmp1    ; screen code to show
        sta     (ptr4), y
        dey
        bpl     xrow
        adw     ptr4, #40
        dex
        bpl     ycol
        rts
.endproc

.proc clear_box1
        ldx     #$00
        ldy     #$00
        jsr     fn_get_scrloc

        ldx     #8
        mva     #$00, tmp1
        jmp     clear_next_x
.endproc

.proc clear_box2
        ldx     #$00
        ldy     #$0C
        jsr     fn_get_scrloc

        ldx     #8
        mva     #$00, tmp1
        jmp     clear_next_x
.endproc

.proc _fn_clr_help
        ; clear help texts. X lines of 40 bytes
        mwa     #mhlp1, ptr4
        ldx     #80
        jmp     do_clear
.endproc

.proc _fn_clr_status
        ; clear the status lines. X lines of 40 bytes
        mwa     #sline1, ptr4
        ldx     #80
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

.bss
cs_col: .res 1