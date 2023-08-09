        .export     _bar_setup, _bar_clear, _bar_setcolor, _bar_up, _bar_down, _bar_show
        .import     __PMG_START__

        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "zeropage.inc"

.proc _bar_setup
        lda     _bar_color
        sta     PCOLR0
        sta     PCOLR1
        sta     PCOLR2
        sta     PCOLR3
        
        mva     #>__PMG_START__, PMBASE
        mva     #$03, GRACTL    ; turn on players and missiles

        mva     #$ff, M0PL
        sta           M1PL
        sta           M1PL
        sta           M2PL
        sta           M3PL
        sta           P0PL

        ; positions
        mva     #$30, M0PF
        mva     #$50, M1PF
        mva     #$70, M2PF
        mva     #$90, M2PF
        mva     #$b0, P0PF
        mva     #$b8, P1PF
        mva     #$c0, P2PF
        mva     #$c8, P3PF
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

.proc _bar_setcolor

.endproc

.proc _bar_up

.endproc

.proc _bar_down

.endproc

.proc _bar_show

.endproc

.data
_bar_color:  .byte $44
