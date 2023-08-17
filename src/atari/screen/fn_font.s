        .export     fn_font

        .import     debug

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"


.proc fn_font
        ; copy character set into RAM, amend it, tell app where it is
        ldx     #$00
        ; copy $400 bytes
:       mva     {$e000, x}, {fn_font_data + $0000, x}
        mva     {$e100, x}, {fn_font_data + $0100, x}
        mva     {$e200, x}, {fn_font_data + $0200, x}
        mva     {$e300, x}, {fn_font_data + $0300, x}
        inx
        bne     :-

        ; copy the changes
        ldx     #$00
all_fonts:
        mwa     #$00, tmp1      ; reset tmp1/2 which will contain position x 8

        lda     font_update, x  ; position
        inx
        ldy     #$03        ; 2^3 = 8
:       asl     a
        rol     tmp2
        dey
        bne     :-
        sta     tmp1    ; low byte of x8, tmp2 has highbyte

        mwa     #fn_font_data, ptr1
        adw     ptr1, tmp1      ; adjust ptr1 by the offset

        ; copy 8 bytes from our font data into the target font set
        ldy     #$00
        sty     tmp1    ; initialise our 8 counter
:       mva     {font_update, x}, {(ptr1), y}
        inx
        iny
        inc     tmp1
        lda     tmp1
        cmp     #$08
        bne     :-

        cpx     #54     ; currently 6 chars x 9 bytes per char
        bcc     all_fonts

        mva     #>fn_font_data, CHBAS

        rts
.endproc

.segment "FONT"
fn_font_data:   .res $400

.segment "SCREEN"
; character changes. First byte is the offset (x8) into font data + 8 bytes to define char
font_update:
    .byte $40, $00, $70, $8e, $fe, $fe, $fe, $fe, $00   ; dir symbol (ascii 0   = $00)
    .byte $41, $03, $07, $07, $07, $07, $07, $07, $03   ; L ender    (ascii 1   = $01)
    .byte $42, $c0, $e0, $e0, $e0, $e0, $e0, $e0, $c0   ; R ender    (ascii 2   = $02)
    .byte $44, $c3, $e7, $e7, $e7, $e7, $e7, $e7, $c3   ; Tween end  (ascii 4   = $04)
    .byte $7b, $00, $0e, $18, $18, $70, $18, $18, $0e   ; {          (ascii 123 = $7B)
    .byte $7d, $00, $70, $18, $18, $0e, $18, $18, $70   ; }          (ascii 125 = $7D)
