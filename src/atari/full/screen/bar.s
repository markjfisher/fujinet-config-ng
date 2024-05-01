        .export     _bar_setup, _bar_clear, _bar_setcolor, _bar_show

        .import     __PMG_START__
        .import     _wait_scan1
        .import     popa
        .import     return0

        .include    "atari.inc"
        .include    "macros.inc"
        .include    "zp.inc"

.proc _bar_setup
        lda     #$44
        jsr     _bar_setcolor

        mva     #>__PMG_START__, PMBASE
        ;; causes flicker here
        ; mva     #$03, GRACTL    ; turn on players and missiles

        mva     #$ff, SIZEP0
        sta           SIZEP1
        sta           SIZEP2
        sta           SIZEP3
        sta           SIZEM

        ; set positions M0PF to P3PF from bar_positions table
        mwa     #bar_positions, tmp9
        ldy     #$07
:       mva     {(tmp9), y}, {M0PF, y}
        dey
        bpl     :-

        ;; causes flicker here
        ; jsr     _wait_scan1
        ; mva     #$03, GRACTL    ; turn on players and missiles
        rts
.endproc

.proc _bar_clear
        mwa     #__PMG_START__+384, tmp5
        mwa     #__PMG_START__+512, tmp7
        mwa     #__PMG_START__+768, tmp9

        lda     #$00
        tay
:       sta     (tmp5), y
        sta     (tmp7), y
        sta     (tmp9), y
        iny
        bne     :-
        rts
.endproc

; void bar_setcolor(uint8_t newColor)
.proc _bar_setcolor
        sta     PCOLR0
        sta     PCOLR1
        sta     PCOLR2
        sta     PCOLR3
        rts
.endproc

; void bar_show(uint8_t row, uint8_t offset)
.proc _bar_show
        sta     tmp10   ; highlight offset for currently viewed module, forces PMG down screen a bit as we don't always start on first line.

        jsr     popa
        sec
        adc     #$00    ; get row 1 based
        asl     a       ; row x 2
        asl     a       ; row x 4
        adc     tmp10   ; adjustment fudge, this positions the bar over current item
        pha             ; save a
        jsr     _wait_scan1
        jsr     _bar_clear
        pla
        tax

        ldy     #$04
        lda     #$ff    ; shape data in A
:       sta     __PMG_START__+$180, x
        sta     __PMG_START__+$200, x
        sta     __PMG_START__+$280, x
        sta     __PMG_START__+$300, x
        sta     __PMG_START__+$380, x
        inx
        dey
        bne     :-
        ; delay turning on PM graphics all the way to when it's being used.
        ; doesn't seem to hurt leaving it keep being set here.
        mva     #$03, GRACTL    ; turn on players and missiles

        jmp     return0
.endproc

.rodata
bar_positions:  .byte $30, $50, $70, $90, $b0, $b8, $c0, $c8
