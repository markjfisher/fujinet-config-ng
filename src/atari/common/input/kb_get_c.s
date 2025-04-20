        .export     _kb_get_c
        .export     _kb_get_c_ucase

        .import     _kbhit
        .import     reset_joy_state

        .include    "macros.inc"
        .include    "atari.inc"

; char _kb_get_c()
;
; non blocking keyboard fetch of single char, returns 0 in A if no key, otherwise atascii code
; resets CLOCK if key pressed
.proc _kb_get_c
        jsr     _kbhit
        beq     no_key

        ; when a key is pressed, reset the joystick states
        jsr     reset_joy_state

        mva     #$00, RTCLOK
        sta           RTCLOK+1
        sta           RTCLOK+2
        jmp     get_key
        ; implicit rts

no_key:
        tax             ; this is now called from C so ensure X is set appropriately
        cmp     #$00
        rts
.endproc

; _kb_get_c_ucase()
;
; force return into upper case
.proc _kb_get_c_ucase
        jsr     _kb_get_c
        cmp     #'a'
        bcc     out
        cmp     #'z'+1
        bcs     out
        and     #$df    ; remove bit 5

out:
        rts
.endproc

; char get_key(void)
;
; no frills keyboard routine with no cursor support, based on cgetc
.proc get_key
        mva     #12, ICAX1Z     ; ensure calling KEYBDV directly will work
        jsr     do_kb
        ldx     #$00
        cmp     #$00    ; set bit flags
        rts

do_kb:  lda     KEYBDV+5
        pha
        lda     KEYBDV+4
        pha
        rts     ; JMP via dispatch
.endproc