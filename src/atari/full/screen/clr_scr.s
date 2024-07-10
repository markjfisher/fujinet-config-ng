        .export     _clr_scr_all
        .export     _clr_scr_with_separator
        .export     _clr_help
        .export     _clr_status

        .import     get_scrloc
        .import     mhlp1, sline1, m_l1

        .import     debug, _pause

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

; clears the internal screen and the help and status texts
.proc _clr_scr_all
        jsr     _clr_scr
        jsr     _clr_status
        jmp     _clr_help
.endproc

.proc clr_scr_inner
        mwa     #m_l1, tmp9     ; don't need get_scrloc, as we are at 0,0
        adw1    tmp9, #$01      ; just need to move 1 byte inside border

        ldx     #21     ; rows-1
ycol:   ldy     #SCR_WID_NB-1 ; usable width - 1 
        lda     #$00    ; screen code for ' '
xrow:   sta     (tmp9), y
        dey
        bpl     xrow
        adw1    tmp9, #SCR_BYTES_W
        dex
        bpl     ycol
        rts
.endproc

.proc _clr_scr
        jsr     clr_scr_inner
        ldy     #$00            ; forces a simple border
        jmp     draw_border     ; with no separators
.endproc

; y holds the line at which a separator should be drawn, 0 for no separator
.proc draw_border
        mwa     #m_l1, tmp9
        dey             ; make it 0 indexed, if no separator required, y becomes $ff, which means we'll never print it
        sty     tmp8
        ldx     #$00    ; current row    
all_loop:
        ldy     #$00    ; current char on line
        cpx     tmp8
        beq     do_separator

        ; normal border
        mva     #FNC_LT_BLK, {(tmp9), y}
        ldy     #SCR_WIDTH-1
        mva     #FNC_RT_BLK, {(tmp9), y}
        iny
        adw1    tmp9, #SCR_BYTES_W                ; move tmp9 to start of next line
        inx
        bne     next

do_separator:
        stx     tmp7            ; store the current line index
        lda     #FNC_BL_SEP
        sta     (tmp9), y
        iny
        ldx     #SCR_WIDTH-2
        lda     #FNC_MD_SEP
:       sta     (tmp9), y
        iny
        dex
        bne     :-

        lda     #FNC_BR_SEP
        sta     (tmp9), y
        adw1    tmp9, #SCR_BYTES_W

        ldx     tmp7
        inx
next:
        cpx     #22
        bne     all_loop
        rts
.endproc

; void clr_src_with_separator(uint8_t separator_line)
;
; clear screen and place a separator on page at line separator_line (1 based index)
.proc _clr_scr_with_separator
        pha                             ; save the separator_line
        jsr     clr_scr_inner           ; clear the inner part of screen
        pla                             ; restore parameter
        tay
        jmp     draw_border             ; ... and draw border with param in Y index
.endproc

.proc _clr_help
        ; clear help texts. Currently 1 lines of SCR_WIDTH bytes, stored as SCR_BWX2 to save calculating
        mwa     #mhlp1, tmp9
        ldx     #SCR_WIDTH
        jmp     x_inv_spaces
.endproc

.proc _clr_status
        ; clear the status lines. Currently 2 lines of SCR_WIDTH bytes, stored as SCR_BWX2 to save calculating
        mwa     #sline1, tmp9
        ldx     #SCR_BWX2
        jmp     x_inv_spaces
.endproc

.proc x_inv_spaces
        ldy     #$00
        lda     #FNC_FULL       ; inverse space
:       sta     (tmp9), y
        iny
        dex
        bne     :-
        rts
.endproc
