        .export     _bar_setup, _bar_clear, _bar_setcolor, _bar_up, _bar_down, _bar_show
        .import     __PMG_START__, _wait_scan1

        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "zeropage.inc"

.proc _bar_setup
        lda     #$44
        jsr     _bar_setcolor

        mva     #>__PMG_START__, PMBASE
        mva     #$03, GRACTL    ; turn on players and missiles

        mva     #$ff, M0PL
        sta           M1PL
        sta           M2PL
        sta           M3PL
        sta           P0PL

        ; set positions M0PF to P3PF from bar_positions table
        mwa     #bar_positions, ptr1
        ldy     #$07
:       mva     {(ptr1), y}, {M0PF, y}
        dey
        bpl     :-

        rts
.endproc

.proc _bar_clear
        ; clear __PMG_START__ for 1024 bytes, which is 4 pages
        ldx     #$04
        mwa     #__PMG_START__, ptr1
        lda     #$00
        ldy     #$00
:       sta     (ptr1), y
        iny
        bne     :-
        inc     ptr1+1
        dex
        bne     :-
        rts
.endproc

; void bar_setcolor(uint8 newColor)
.proc _bar_setcolor
        sta     PCOLR0
        sta     PCOLR1
        sta     PCOLR2
        sta     PCOLR3
.endproc

.proc _bar_up
        rts
.endproc

.proc _bar_down
        rts
.endproc

; void bar_show(uint8 y)
.proc _bar_show
        sec
        adc     #$00    ; get it 1 based

        asl     a       ; row x 2
        asl     a       ; row x 4
        adc     #$20    ; adjustment fudge, this positions the bar over current item
        pha             ; save a
        jsr     _wait_scan1
        jsr     _bar_clear
        pla
        tax

        ldy     #$04
:       lda     #$0f        ; shape data in A, these 2 shorten the PM at start and end to be within border
        sta     __PMG_START__+$180, x
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
