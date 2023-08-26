        .export     _bar_setup, _bar_clear, _bar_setcolor, _bar_show
        .import     __PMG_START__, _wait_scan1

        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "zeropage.inc"

.proc _bar_setup
        lda     #$44
        jsr     _bar_setcolor

        mva     #>__PMG_START__, PMBASE
        mva     #$03, GRACTL    ; turn on players and missiles

        mva     #$ff, SIZEP0
        sta           SIZEP1
        sta           SIZEP2
        sta           SIZEP3
        sta           SIZEM

        ; set positions M0PF to P3PF from bar_positions table
        mwa     #bar_positions, ptr1
        ldy     #$07
:       mva     {(ptr1), y}, {M0PF, y}
        dey
        bpl     :-

        rts
.endproc

.proc _bar_clear
        ; clear __PMG_START__ for from 384+28 to 1024 bytes
        ; OLD: The extra 28 come from the fact the PMG is not shown in first 7 lines (4 bytes per line)
        mwa     #__PMG_START__+384, ptr2        ; slight overlap here, but really doesn't matter
        mwa     #__PMG_START__+512, ptr3
        mwa     #__PMG_START__+768, ptr4
        lda     #$00
        ldy     #$00
:
        sta     (ptr2), y
        sta     (ptr3), y
        sta     (ptr4), y
        iny
        bne     :-
        rts
.endproc

; void bar_setcolor(uint8 newColor)
.proc _bar_setcolor
        sta     PCOLR0
        sta     PCOLR1
        sta     PCOLR2
        sta     PCOLR3
        rts
.endproc

; void bar_show(uint8 row(A), uint8 offset(X))
.proc _bar_show
        stx     tmp1    ; highlight offset for currently viewed module, forces PMG down screen a bit as we don't always start on first line.
        sec
        adc     #$00    ; get row 1 based

        asl     a       ; row x 2
        asl     a       ; row x 4
        adc     tmp1    ; adjustment fudge, this positions the bar over current item
        pha             ; save a
        jsr     _wait_scan1
        jsr     _bar_clear
        pla
        tax

        ldy     #$04
:       lda     #$bf    ; shape data in A, these 2 shorten the PM at start and end to be within border
        sta     __PMG_START__+$180, x
        lda     #$7f
        sta     __PMG_START__+$200, x
        lda     #$ff
        sta     __PMG_START__+$280, x
        sta     __PMG_START__+$300, x
        sta     __PMG_START__+$380, x
        inx
        dey
        bne     :-

        ; exit with 0 in A, X
        ldx     #$00
        lda     #$00
        rts
.endproc

.rodata
bar_positions:  .byte $30, $50, $70, $90, $b0, $b8, $c0, $c8
