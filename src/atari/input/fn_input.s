        .export     _fn_input, _fn_input_ucase
        .import     _kbhit

        .include    "fn_macros.inc"
        .include    "atari.inc"

; char get_key(void)
;
; no frills keyboard routine with no cursor support, based on cgetc
.proc get_key
        mva     #12, ICAX1Z     ; ensure calling KEYBDV directly will work
        jsr     do_kb
        ldx     #0
        rts

do_kb:  lda     KEYBDV+5
        pha
        lda     KEYBDV+4
        pha
        rts     ; JMP via dispatch
.endproc

; char fn_input()
;
; non blocking keyboard fetch of single char
.proc _fn_input
        jsr     _kbhit
        beq     no_key
        mva     #$00, RTCLOK
        sta           RTCLOK+1
        sta           RTCLOK+2
        jmp     get_key

no_key:
        rts
.endproc

; fn_input_ucase()
;
; force return into upper case
.proc _fn_input_ucase
        jsr     _fn_input
        cmp     #'a'
        bcc     out
        cmp     #'z'+1
        bcs     out
        and     #$df    ; remove bit 5

out:
        rts
.endproc