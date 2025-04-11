        .export     _bar_setup, _bar_clear, _bar_setcolor, _bar_show
        .export     _pmg_space_left
        .export     _pmg_space_right

        .import     __PMG_START__
        .import     _wait_scan1
        .import     return0

        .import     debug

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

; _pmg_space_left = number of characters to skip from the left

.proc _bar_show
        sta     tmp10   ; highlight offset for currently viewed module, forces PMG down screen a bit as we don't always start on first line.

        iny             ; make row 1 based 
        tya
        asl     a       ; row x 2
        asl     a       ; row x 4
        adc     tmp10   ; adjustment fudge, this positions the bar over current item
        pha             ; save a

        jsr     _wait_scan1
        jsr     _bar_clear
        jsr     calc_shape_data

        pla
        tax
        mva     #$04, tmp1      ; set counter to 4

        ; end of the PMG line (i know, it's weird), and nybles are reversed, so BF is F on left, B on right, and then the sub-nyble is inverted, so bits are 1,0,3,2. so B = 1110. thus BF = 1111,1110 in PMG pixels.
        ; and as 1 bit in PMG = 1 char on screen, this means all but the last char of the line are highlighted.
        ; ONLY +$180 has this weird behaviour because it's missiles I think. all the others are normal left to right reading, and $200 is the start of the PMG line.

:
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

        ; the MISSILE data goes at the end of the line, but in memory it's before the others. Rearranging to make the array easier to calculate as a list from left to right
        lda     shape_data, y
        sta     __PMG_START__+$180, x
        inx

        dec     tmp1
        bne     :-
        ; delay turning on PM graphics all the way to when it's being used.
        ; doesn't seem to hurt leaving it keep being set here.
        mva     #$03, GRACTL    ; turn on players and missiles

        jmp     return0

; about 24 more bytes than previous implementation but faster for larger X values
; as it doesn't have to keep LSR through all values
calc_shape_data:
        ldx     #$00
        stx     tmp1                    ; initialise div8 result.

        ; write defaults into last 4 bytes, the first byte is always calculated as _pmg_space_left is never 0
        lda     #$ff
        ldy     #$04
:       sta     shape_data, y
        dey
        bne     :-

        lda     _pmg_space_left

        cmp     #8                      ; don't do div8 if it's under 8
        bcc     lhs_under_8
        tay

        ; work out space div 8
        lsr     a                       ; / 2
        lsr     a                       ; / 4
        lsr     a                       ; / 8
        tax                             ; number of whole bytes to set to 0
        sta     tmp1                    ; save the div value as the index into our array for non-whole part, this is correct value without needing to 0 index it
        lda     #$00
:       sta     shape_data-1, x
        dex
        bne     :-

        tya                             ; restore X value
        and     #$07                    ; remainder of X div 8

lhs_under_8:
        beq     lhs_done
        tay
        dey                             ; make it 0 indexed
        lda     left_bit_masks, y       ; pre-calculated LSR values for the remainder part
        ldx     tmp1                    ; restore the index into array output (the div8 result)
        sta     shape_data, x

lhs_done:
        ; jsr     debug
        ; now calculate the rhs
        lda     _pmg_space_right
        cmp     #8
        bcc     missile_only

        lsr     a                       ; / 2
        lsr     a                       ; / 4
        lsr     a                       ; / 8, A = space div 8
        tay                             ; store the div result, we need to count down to 0 on this

        ; set the number of bytes in A from end of the array backwards to value 0
        ; calculate (5 - a) to give a value we can use as an x index. a is always at least 1, as we tested it was >= 8 already
        ; thus 5 - a = 4 for a = 1, which is the index for the last byte.
        sec
        sbc     #5
        eor     #$ff
        sta     tmp1                    ; this is the index that we will need to change for the non-whole 00 byte
        tax                             ; N-A calculation usually uses eor / clc / adc #1, but as we're transferring to x, this is 1 byte shorter
        inx                             ; this is the byte index, and we can increment it as we loop down y
        lda     #$00
:       sta     shape_data, x
        inx
        dey
        bne     :-

        ; get the remainder
        lda     _pmg_space_right
        and     #$07
        beq     rhs_done
        tay
        dey                             ; 0 based index of remainder into right_bit_masks table
        lda     right_bit_masks, y
        ldx     tmp1                    ; recall the index of the byte to alter
        ; however, we don't just set it, we have to honour any left side 0s in the byte from previous blanking
        ; e.g. the byte could be 00111111, but we have the mask 11111110 to just remove one bit from right side, so we simply AND the values together
        and     shape_data, x
        sta     shape_data, x

rhs_done:
        rts

missile_only:
        tax                             ; count of bits to blank, and index into right_side_gap
        lda     right_side_gap, x
        sta     shape_data+4            ; always last byte
        rts

.endproc

.data
_pmg_space_left:        .byte 1
_pmg_space_right:       .byte 1

; the PMG mask values to print, these will be overwritten depending on the _pmg_space_left and _pmg_space_right values set by calling functions
shape_data:             .byte $ff, $ff, $ff, $ff, $ff

.rodata
bar_positions:          .byte $30, $50, $70, $90, $b0, $b8, $c0, $c8

; due to the missiles odd way of representing pixels on the LHS of the bar, we store the values to set as a table
right_side_gap:         .byte $ff, $bf, $3f, $2f, $0f, $0b, $03, $02

; these are 1 based index values for the PMG value that cover N spaces to the left
left_bit_masks:         .byte %01111111, %00111111, %00011111, %00001111, %00000111, %00000011, %00000001
right_bit_masks:        .byte %11111110, %11111100, %11111000, %11110000, %11100000, %11000000, %10000000