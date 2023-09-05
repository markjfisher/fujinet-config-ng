        .export     _clr_scr_all, _clr_help, _clr_status, _clr_scr_all, _clr_scr_files
        .import     get_scrloc
        .import     mhlp1, sline1, m_l1
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; clears the internal screen of our 36x16 display, and the help and status texts
.proc _clr_scr_all
        jsr     _clr_scr
        jsr     _clr_status
        jmp     _clr_help
.endproc

; just the page and 1 char of blank border
.proc _clr_scr
        ldx     #$00
        ldy     #$00
        jsr     get_scrloc
        sbw     ptr4, #$01      ; move into border char, we're clearing extra width to cater for anyone doing separators that are in border

        ldx     #19     ; rows-1
ycol:   ldy     #37     ; width - 2 (so include borders), yeah, we need Y as the index for x col...
        lda     #$00    ; screen code for ' '
xrow:   sta     (ptr4), y
        dey
        bpl     xrow
        adw1    ptr4, #SCR_WIDTH
        dex
        bpl     ycol
        rts
.endproc

; TODO: Move this, make more generic to any size, not just "line 4"
.proc _clr_scr_files
        jsr     _clr_scr

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

.proc _clr_help
        ; clear help texts. Currently 2 lines of SCR_WIDTH bytes, stored as SCR_WIDTHX2 to save calculating
        mwa     #mhlp1, ptr4
        ldx     #SCR_WIDTHX2
        jmp     do_clear
.endproc

.proc _clr_status
        ; clear the status lines. Currently 2 lines of SCR_WIDTH bytes, stored as SCR_WIDTHX2 to save calculating
        mwa     #sline1, ptr4
        ldx     #SCR_WIDTHX2
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
