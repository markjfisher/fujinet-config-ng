        .export     _clr_scr_all
        .export     _clr_scr_with_separator
        .export     _clr_help
        .export     _clr_status
        .export     screen_separators
        .export     draw_border

        .import     get_scrloc
        .import     mhlp1, sline1, m_l1
        .import     _pause

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

; clears the internal screen and the help and status texts
_clr_scr_all:
        jsr     _clr_scr
        jsr     _clr_status
        jmp     _clr_help

clr_scr_inner:
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

_clr_scr:
        jsr     clr_scr_inner
        ldy     #$00            ; forces a simple border

        ; fall through to draw_border
        ; jmp     draw_border     ; with no separators

; draws separators at the screen_separator locations
; y holds the number of separators to print (0-4)
; screen_separators array contains the 0-based line numbers where separators should be drawn
draw_border:
        mwa     #m_l1, tmp9
        sty     tmp8            ; store number of separators
        
        ; Initialize next separator tracking
        lda     #$00
        sta     tmp6            ; separator array index
        sta     tmp5            ; current row counter (0-based)
        cpy     #$00            ; check if we have any separators
        beq     no_separators
        lda     screen_separators  ; get first separator line
        bne     have_separator
no_separators:
        lda     #$ff            ; no separators, use $ff so it never matches
have_separator:
        sta     tmp7            ; tmp7 holds next separator line number
        
all_loop:
        lda     tmp5            ; get current row
        cmp     tmp7            ; check if current row is separator
        bne     normal_border
        
        ; We found a separator line, draw it and get next separator
        ldy     #$00
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
        
        ; Get next separator if any
        inc     tmp6            ; move to next separator
        ldx     tmp6
        cpx     tmp8            ; compare with total separators
        bcs     no_more_seps    ; if >= total seps, no more
        lda     screen_separators,x ; get next separator
        bne     have_next_sep
no_more_seps:
        lda     #$ff            ; no more separators, use $ff
have_next_sep:
        sta     tmp7            ; store next separator line
        bne     next_row        ; always branch
        
normal_border:
        ldy     #$00
        mva     #FNC_LT_BLK, {(tmp9), y}
        ldy     #SCR_WIDTH-1
        mva     #FNC_RT_BLK, {(tmp9), y}

next_row:
        adw1    tmp9, #SCR_BYTES_W    ; move tmp9 to start of next line
        inc     tmp5                   ; increment current row
        lda     tmp5
        cmp     #22
        bne     all_loop
        rts

; void clr_src_with_separator(uint8_t separator_line)
;
; clear screen and place any separators. count is in y
_clr_scr_with_separator:
        tya
        pha                             ; save the separator_line count
        jsr     clr_scr_inner           ; clear the inner part of screen
        pla                             ; restore parameter
        tay
        jmp     draw_border             ; ... and draw border with param in Y index

_clr_help:
        ; clear help texts. Currently 1 lines of SCR_WIDTH bytes, stored as SCR_BWX2 to save calculating
        mwa     #mhlp1, tmp9
        ldx     #SCR_WIDTH
        bne     x_inv_spaces

_clr_status:
        ; clear the status lines. Currently 2 lines of SCR_WIDTH bytes, stored as SCR_BWX2 to save calculating
        mwa     #sline1, tmp9
        ldx     #SCR_BWX2
        ; fall through to ...
        ; jmp     x_inv_spaces

x_inv_spaces:
        ldy     #$00
        lda     #FNC_FULL       ; inverse space
:       sta     (tmp9), y
        iny
        dex
        bne     :-
        rts

.bss
; allow up to 5 separators
screen_separators:      .res 5

