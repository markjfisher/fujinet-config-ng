        .export     _fn_clrscr_all, _fn_clr_help, _fn_clr_status, _fn_clrscr_all, _fn_clrscr_files
        .import     fn_get_scrloc
        .import     mhlp1, sline1, m_l1
        .import     _wait_scan1
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; clears the internal screen of our 36x16 display, and the help and status texts
.proc _fn_clrscr_all
        jsr     _fn_clrscr
        jsr     _fn_clr_status
        jmp     _fn_clr_help
.endproc

; just the page and 1 char of blank border
.proc _fn_clrscr
        ldx     #$00
        ldy     #$00
        jsr     fn_get_scrloc
        sbw     ptr4, #$01      ; move into border char, we're clearing extra width to cater for anyone doing separators that are in border

        ldx     #19     ; rows-1
ycol:   ldy     #37     ; width - 2 (so include borders), yeah, we need Y as the index for x col...
xrow:   lda     #$00    ; screen code for ' '
        sta     (ptr4), y
        dey
        bpl     xrow
        adw     ptr4, #40
        dex
        bpl     ycol
        rts
.endproc

.proc _fn_clrscr_files
        jsr     _fn_clrscr

        ; print the separator bar at line 4
        mwa     #m_l1, ptr4
        adw     ptr4, #120              ; add 3 lines down
        ldy     #$01
        mva     #$57, {(ptr4), y}       ; left bar
        iny
        ldx     #36
        lda     #$52                    ; centre bar char
:       sta     (ptr4), y
        iny
        dex
        bne     :-
        mva     #$58, {(ptr4), y}       ; right bar
        rts
.endproc

.proc _fn_clr_help
        ; clear help texts. X lines of 40 bytes
        mwa     #mhlp1, ptr4
        ldx     #80
        jmp     do_clear
.endproc

.proc _fn_clr_status
        ; clear the status lines. Y lines of 40 bytes
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
