        .export     _clr_scr_all, _clr_help, _clr_status, _clr_scr_all, _clr_scr_files
        .import     get_scrloc
        .import     mhlp1, sline1, m_l1

        .import     debug, _pause

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; clears the internal screen and the help and status texts
.proc _clr_scr_all
        jsr     _clr_scr
        jsr     _clr_status
        jmp     _clr_help
.endproc

.proc clr_scr_inner
        ldx     #$00
        ldy     #$00
        jsr     get_scrloc

        ldx     #19     ; rows-1
ycol:   ldy     #SCR_WIDTH-3
        lda     #$00    ; screen code for ' '
xrow:   sta     (ptr4), y
        dey
        bpl     xrow
        adw1    ptr4, #SCR_BYTES_W
        dex
        bpl     ycol
        rts
.endproc

.proc _clr_scr
        jsr     clr_scr_inner
        ldy     #$00
        jmp     draw_border     ; clears any old separators
.endproc

; y holds the line at which a separator should be drawn, 0 for no border
.proc draw_border
        mwa     #m_l1, ptr4
        dey             ; make it 0 indexed, and now becomes $ff if there was no border, which means we'll never print it
        sty     tmp4
        ldx     #$00    ; current row    
all_loop:
        ldy     #$00    ; current char on line
        cpx     tmp4
        beq     do_separator

        ; normal border
        mva     #FNC_LT_BLK, {(ptr4), y}
        ldy     #SCR_WIDTH-1
        mva     #FNC_RT_BLK, {(ptr4), y}
        iny
        adw1    ptr4, #SCR_BYTES_W                ; move ptr4 to start of next line
        inx
        bne     next

do_separator:
        stx     tmp3            ; store the current line index
        lda     #FNC_BL_SEP
        sta     (ptr4), y
        iny
        ldx     #SCR_WIDTH-2
        lda     #FNC_MD_SEP
:       sta     (ptr4), y
        iny
        dex
        bne     :-

        lda     #FNC_BR_SEP
        sta     (ptr4), y
        adw1    ptr4, #SCR_BYTES_W

        ldx     tmp3
        inx
next:
        cpx     #20
        bne     all_loop
        rts
.endproc

; TODO: Move this, make more generic to any size, not just "line 4"
.proc _clr_scr_files
        jsr     clr_scr_inner
        ldy     #$04
        jmp     draw_border
.endproc

.proc _clr_help
        ; clear help texts. Currently 2 lines of SCR_WIDTH bytes, stored as SCR_BWX2 to save calculating
        mwa     #mhlp1, ptr4
        ldx     #SCR_BWX2
        jmp     x_inv_spaces
.endproc

.proc _clr_status
        ; clear the status lines. Currently 2 lines of SCR_WIDTH bytes, stored as SCR_BWX2 to save calculating
        mwa     #sline1, ptr4
        ldx     #SCR_BWX2
        jmp     x_inv_spaces
.endproc

.proc x_inv_spaces
        ldy     #$00
        lda     #FNC_FULL       ; inverse space
:       sta     (ptr4), y
        iny
        dex
        bne     :-
        rts
.endproc
