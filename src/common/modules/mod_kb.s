        .export     mod_kb, current_line, p_current_line
        .import     popa, popax
        .import     mod_current, _fn_put_c, _fn_input_ucase, _dev_highlight_line, _fn_is_option, done_is_booting

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"

; void mod_kb(uint8 offset, uint8 current, uint8 max, uint8 prevMod, uint8 nextMod, void * mod_kb_proc)
;      offset:  the adjustment for line high lighting for current module, e.g. $20 is for devices/hosts
;     current:  the current selected line (zero based)
;         max:  the largest index - 1
;     prevmod:  which mod to go to if press left key
;     nextmod:  which mod to go to if press right key
; mod_kb_proc:  the module specific keyboard routine to check current keypress for. e.g. pressing enter is mod specific
;
; handle keyboard on modules
; common up/down/left/right/option/etc routines in here, then calls mod_kb_proc to handle specific module keyboard input
.proc mod_kb
        ; save the specific module's kb handler
        getax   mod_kb_proc
        ; and pop other params
        popax   p_current_line
        popa    next_mod
        popa    prev_mod
        popa    selected_max

        ; save current_line from ptr to its module specific verson.
        ldy     #$00
        mwa     p_current_line, ptr1
        mva     {(ptr1), y}, current_line

start_kb_get:

        ; check for option to boot
        jsr     _fn_is_option
        beq     not_option
        ; set done module with a flag to say boot
        mva     #$01, done_is_booting
        mva     #Mod::done, mod_current
        rts

not_option:
        jsr     _fn_input_ucase
        cmp     #$00
        beq     start_kb_get          ; simple loop if no key pressed
        pha     ; save it

        ; print the char on screen to see it (debug - TODO: remove)
        ldx     #35
        ldy     #15
        jsr     _fn_put_c

; ----------------------------------------------------------
; KEYBOARD HANDLING SWITCH STATEMENT
; ----------------------------------------------------------

        pla     ; restore it

; -------------------------------------------------
; right - set next module, and exit mod_kb
        cmp     #'*'
        beq     do_right
        cmp     #ATRRW
        beq     do_right
        bne     :+

do_right:
        mva     next_mod, mod_current
        rts

:
; -------------------------------------------------
; left - set prev module, and exit mod_kb
        cmp     #'+'
        beq     do_left
        cmp     #ATLRW
        beq     do_left
        bne     :+

do_left:
        mva     prev_mod, mod_current
        rts

:
; -------------------------------------------------
; 1-8
        cmp     #'1'
        bcs     one_or_over
        bcc     :+
one_or_over:
        cmp     #'9'
        bcs     :+

        ; in range 1-8
        sec
        sbc     #'1' ; convert from ascii for 1-8 to index 0-7
        sta     current_line
        jsr     save_current_line
        jsr     _dev_highlight_line
        jmp     start_kb_get

:
; -------------------------------------------------
; up
        cmp     #'-'
        beq     do_up
        cmp     #ATURW
        beq     do_up
        bne     :+

do_up:
        lda     current_line
        cmp     #0
        beq     out
        dec     current_line
        jsr     save_current_line
        jsr     _dev_highlight_line
        jmp     start_kb_get

:
; -------------------------------------------------
; down
        cmp     #'='
        beq     do_down
        cmp     #ATDRW
        beq     do_down
        bne     :+

do_down:
        lda     current_line
        cmp     selected_max
        bcs     out
        inc     current_line
        jsr     save_current_line
        jsr     _dev_highlight_line
        jmp     start_kb_get

:

        ; run the module's kb routines, we need jsr so we can continue after indirect call
        jsr     do_mod_kb

; may need to move this to middle of the cases so they can branch to it easily, or change to jmps
out:
        ; and reloop if we didn't leave this routine through a kb option
        jmp     start_kb_get


do_mod_kb:
        jmp     (mod_kb_proc)
        ; rts is implicit in the jmp

; write current line back to the module's version
save_current_line:
        ldy     #$00
        mwa     p_current_line, ptr1       ; need to see if anything ever changes ptr1, to make this more efficient
        mva     current_line, {(ptr1), y}
        rts

.endproc

.bss
p_current_line: .res 2
current_line:   .res 1
mod_kb_proc:    .res 2
selected_max:   .res 1
next_mod:       .res 1
prev_mod:       .res 1
