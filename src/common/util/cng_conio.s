        .export     cng_cputc
        .export     cng_cputs
        .export     cng_gotoxy

        .import    ascii_to_code

        .import    _mul40
        .import    _revflag
        .import    popa

        .include    "atari.inc"
        .include    "zp.inc"

; These are replacements for conio functions
; with the cursor handling stripped out.
;
; This was to stop the screen corruption when using cc65's versions
; after using direct screen manipution in popups etc.
; A better fix would be to fully use cc65's conio rather than use
; both, but this fix is good enough for now.
; Also, moving to conio fully would slow the screen drawing down, which uses direct ptr manipulation to find screen locations
; whereas conio tends to do lots of mul40 to get to locations.


; void cng_gotoxy(uint8_t x, uint8_t y)
cng_gotoxy:        
        sta     ROWCRS          ; Set Y
        jsr     popa            ; Get X
        sta     COLCRS          ; Set X
        lda     #0
        sta     COLCRS+1
        rts

; void cng_cputc(char a)
cng_cputc:
        cmp     #$0D            ; CR
        bne     L4
        lda     #0
        sta     COLCRS
        beq     plot            ; return

L4:     cmp     #$0A            ; LF
        beq     newline
        cmp     #ATEOL          ; Atari-EOL?
        beq     newline

        jsr     ascii_to_code

cputdirect:                     ; accepts screen code
        jsr     putchar

; advance cursor
        inc     COLCRS
        lda     COLCRS
        cmp     #40
        bcc     plot
        lda     #0
        sta     COLCRS

newline:
        inc     ROWCRS
        lda     ROWCRS
        cmp     #24
        bne     plot
        lda     #0
        sta     ROWCRS
plot:   ; jsr     setcursor
        ldy     COLCRS
        ldx     ROWCRS
        rts

putchar:
        pha                     ; save char

        lda     ROWCRS
        jsr     _mul40          ; destroys tmp4, carry is cleared
        adc     SAVMSC          ; add start of screen memory
        sta     ptr4
        txa
        adc     SAVMSC+1
        sta     ptr4+1
        pla                     ; get char again

        ora     _revflag

        ldy     COLCRS
        sta     (ptr4),y
        rts

; void cng_cputs(char *s)
cng_cputs:
        sta     ptr1            ; Save s
        stx     ptr1+1

L0:     ldy     #0              ; (2)
L1:     lda     (ptr1),y        ; (7)
        beq     L9              ; (9)  Jump if done
        iny
        sty     tmp1            ; (14) Save offset
        jsr     cng_cputc       ; (20) Output char
        ldy     tmp1            ; (23) Get offset
        bne     L1              ; (25) Next char
        inc     ptr1+1          ; (30) Bump high byte
        bne     L1

L9:     rts