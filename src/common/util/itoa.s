        .export     itoa_2digits
        .export     itoa_args

        .import     _div_i16_by_i8
        .import     pusha

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "itoa.inc"

.segment "CODE2"

; converts value in itoa_input to a 2 digit string in itoa_buf
; doesn't check bounds, so if it's over decimal 99, you'll get weird chars in first digit

itoa_2digits:
        pusha   #10                     ; denominator
        lda     itoa_args+ITOA_PARAMS::itoa_input
        ldx     #$00
        ; ensure string nul is always set.
        stx     itoa_args+ITOA_PARAMS::itoa_buf+2

        jsr     _div_i16_by_i8          ; A = quotient, X = remainder

        ; add '0' ascii to A and X to bring into printable char range
        ; quotient part moved to Y
        clc
        adc     #'0'
        tay
        ; remainder part moved to A
        txa
        clc
        adc     #'0'

        ; if not 0, we print the leading 0
        ldx     itoa_args+ITOA_PARAMS::itoa_show0
        bne     :+

        ; do the check
        ; if we're under 10 then the quotient will be '0' ascii
        cpy     #'0'
        beq     under_10

:       sty     itoa_args+ITOA_PARAMS::itoa_buf
        sta     itoa_args+ITOA_PARAMS::itoa_buf+1
        ; guaranteed to be not 0, as we added 0x30 to get ascii char
        bne     :+

under_10:
        sta     itoa_args+ITOA_PARAMS::itoa_buf
        mva     #$00, itoa_args+ITOA_PARAMS::itoa_buf+1

        ; result is in itoa_args+ITOA_PARAMS::itoa_buf
:       rts

.segment "BANK"
itoa_args:      .tag ITOA_PARAMS
