        .export     fn_font

        .import     debug

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"


NUM_CHANGES     := 14

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

        cpx     #NUM_CHANGES * 9
        bcc     all_fonts

        mva     #>fn_font_data, CHBAS

        rts
.endproc

.segment "FONT"
fn_font_data:   .res $400

.segment "SCREEN"
; character changes. First byte is the offset (x8) into font data, then 8 bytes to define char
font_update:
    .byte $40, $00, $70, $8e, $fe, $fe, $fe, $fe, $00   ; dir symbol (ascii 0   = $00)
    .byte $41, $03, $07, $07, $07, $07, $07, $07, $03   ; L ender    (ascii 1   = $01)
    .byte $42, $c0, $e0, $e0, $e0, $e0, $e0, $e0, $c0   ; R ender    (ascii 2   = $02)
    .byte $44, $c3, $e7, $e7, $e7, $e7, $e7, $e7, $c3   ; Tween end  (ascii 4   = $04)
    .byte $46, $00, $00, $00, $00, $01, $07, $0f, $0f   ; Popup TL   (ascii 6   = $06)
    .byte $47, $00, $00, $00, $00, $80, $e0, $f0, $f0   ; Popup TR   (ascii 7   = $07)
    .byte $48, $0f, $0f, $07, $01, $00, $00, $00, $00   ; Popup BL   (ascii 8   = $08)
    .byte $49, $f0, $f0, $e0, $80, $00, $00, $00, $00   ; Popup BR   (ascii 9   = $09)
    .byte $4a, $00, $00, $00, $00, $1f, $7f, $ff, $ff   ; Popup TLW  (ascii 10  = $0A)
    .byte $4b, $00, $00, $00, $00, $f8, $fe, $ff, $ff   ; Popup TRW  (ascii 11  = $0B)
    .byte $4c, $ff, $ff, $7f, $1f, $00, $00, $00, $00   ; Popup BLW  (ascii 12  = $0C)
    .byte $4f, $ff, $ff, $fe, $f8, $00, $00, $00, $00   ; Popup BRW  (ascii 15  = $0F)
    .byte $7b, $00, $0e, $18, $18, $70, $18, $18, $0e   ; {          (ascii 123 = $7B)
    .byte $7d, $00, $70, $18, $18, $0e, $18, $18, $70   ; }          (ascii 125 = $7D)
