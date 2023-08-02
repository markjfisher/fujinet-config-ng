        .export     put_digit
        .import     m_l1, popa
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void put_digit(uint8 x, uint8 y, uint8 n)
;
; print a digit at the screen location x, y accounting for boundaries
; x and y are in 36x16 grid, so can assume under these values
.proc put_digit
        ; our display is 36x16 grid within the bounds of outer grid, so need to put it to correct place
        sta     tmp3
        jsr     popa
        tax                 ; y coordinate (y reg is trashed by popa)
        popa    tmp4        ; x coordinate

        mwa     #m_l1, ptr3   ; start of screen memory
        adw     ptr3, #$02    ; shift inside boundary

        ; add x coordinate to ptr3
        lda     ptr3
        clc
        adc     tmp4
        sta     ptr3
        bcc     :+
        inc     ptr3 + 1

        ; now move down in lines of 40, y times
:       dex
        bmi     out
        adw     ptr3, #40     ; 40 bytes per row
        clc
        bcc     :-

out:
        ; ptr3 points to screen location, put the digit to screen
        lda     tmp3
        adc     #$10    ; screen code for digit is $10 + digit
        ldy     #$00
        sta     (ptr3), y

        rts
.endproc
