        .export     _bar_setup, _bar_clear, _bar_setcolor, _bar_show
        .export     _pmg_skip_x

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
        ; 0 to 384 left alone for application data etc.
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

; bar_show
; INPUT: A = uint8_t offset (displacement from the top)
;        Y = uint8_t row (0 based index to use for which row to print)

; _pmg_skip_x = number of characters to skip from the left

.proc _bar_show
        sta     tmp10   ; highlight offset for currently viewed module, forces PMG down screen a bit as we don't always start on first line.

        tya             ; get row
        sec
        adc     #$00    ; get row 1 based
        asl     a       ; row x 2
        asl     a       ; row x 4
        adc     tmp10   ; adjustment fudge, this positions the bar over current item
        pha             ; save a

        jsr     _wait_scan1
        jsr     _bar_clear
        jsr     calc_shape_data

        pla
        tax
        mva     #$04, tmp1      ; our counter to 4

        ldy     #$00
        ; end of the PMG line (i know, it's weird), and nybles are reversed, so BF is F on left, B on right, and then the sub-nyble is inverted, so bits are 1,0,3,2. so B = 1110. thus BF = 1111,1110 in PMG pixels.
        ; and as 1 bit in PMG = 1 char on screen, this means all but the last char of the line are highlighted.
        ; ONLY +$180 has this weird behaviour because it's missiles I think. all the others are normal left to right reading, and $200 is the start of the PMG line.
:       lda     #$bf
        sta     __PMG_START__+$180, x

        ; read the calculated value for the X position on the screen we want to highlight from into our shape value
        ldy     #$00
        lda     shape_data, y
        iny
        sta     __PMG_START__+$200, x

        lda     shape_data, y
        iny
        sta     __PMG_START__+$280, x

        lda     shape_data, y
        iny
        sta     __PMG_START__+$300, x

        lda     shape_data, y
        iny
        sta     __PMG_START__+$380, x
        inx

        dec     tmp1
        bne     :-
        ; delay turning on PM graphics all the way to when it's being used.
        ; doesn't seem to hurt leaving it keep being set here.
        mva     #$03, GRACTL    ; turn on players and missiles

        jmp     return0

calc_shape_data:
        ldx     _pmg_skip_x
        ; X is the number of bits from left of shape_data to set to 0 for the PMG shape so that it becomes blank on the screen for 0 .. x-1 chars

        ; initialise shape data to all $ff in case another caller had longer space
        lda     #$ff
        ldy     #$04
:       sta     shape_data-1, y
        dey
        bne     :-

        cpx     #$00
        beq     done

        ; y = 0, a = $ff, x = count of chars / bits to skip in $ff's from left
:       lsr     a               ; drop a bit off from the left
        beq     all_0           ; must have looped 8 times
cont_looping:
        dex
        bne     :-              ; loop until we have done all bits
        sta     shape_data, y       ; set the whole byte

done:   rts

all_0:
        sta     shape_data, y       ; set the whole byte to 0
        iny                     ; move to next byte in table
        lda     #$ff            ; start again with all bits set
        bne     cont_looping

.endproc

.data
_pmg_skip_x:     .byte 1

; the PMG mask values to print
shape_data:
        .byte $7f, $ff, $ff, $ff

.rodata
bar_positions:  .byte $30, $50, $70, $90, $b0, $b8, $c0, $c8
