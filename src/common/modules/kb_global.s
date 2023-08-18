        .export     kb_global, current_line, p_current_line
        .import     popa, popax
        .import     mod_current, fn_put_c, _fn_input_ucase, _fn_highlight_line, _fn_is_option, done_is_booting

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"

; void kb_global(uint8 offset, uint8 current, uint8 max, uint8 prevMod, uint8 nextMod, void * kb_mod_proc)
;      offset:  the adjustment for line high lighting for current module, e.g. $20 is for devices/hosts
;     current:  the current selected line (zero based)
;         max:  the largest index - 1
;     prevmod:  which mod to go to if press left key
;     nextmod:  which mod to go to if press right key
; kb_mod_proc:  the module specific keyboard routine to check current keypress for. e.g. pressing enter is mod specific
;
; handle keyboard on modules
; common up/down/left/right/option/etc routines in here, then calls kb_mod_proc to handle specific module keyboard input
.proc kb_global
        ; save the specific module's kb handler
        axinto  kb_mod_proc
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
        jsr     fn_put_c

; ----------------------------------------------------------
; KEYBOARD HANDLING SWITCH STATEMENT
; ----------------------------------------------------------

        pla             ; get keyboard ascii code into A
        ldx     #$00    ; status of module keyboard handler set in x on return

        ; use module specific keyboard handler first, so we can override default handling, e.g. L/R arrow keys may not move modules
        jsr     do_kb_module

        ; if X=0, then we use global kb handler, as key wasn't processed, A is still keycode
        cpx     #$00
        beq     global_kb

        cpx     #$01    ; if X=1, processed key, and we can reloop
        beq     start_kb_get

        ; anything else was a code to say we want to exit the keyboard routine altogether
        rts

global_kb:
; -------------------------------------------------
; right - set next module, and exit kb_global
        cmp     #FNK_RIGHT
        beq     do_right
        cmp     #FNK_RIGHT2
        beq     do_right
        bne     :+

do_right:
        mva     next_mod, mod_current
        rts

:
; -------------------------------------------------
; left - set prev module, and exit kb_global
        cmp     #FNK_LEFT
        beq     do_left
        cmp     #FNK_LEFT2
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
        ; check we are on hosts/devices (0, 1). don't trash A it still holds the key pressed
        ldx     mod_current
        cpx     #2
        bcs     cont_kb

        ; yes, we are hosts/devices
        sec
        sbc     #'1' ; convert from ascii for 1-8 to index 0-7
        sta     current_line
        jsr     save_current_line
        jsr     _fn_highlight_line
        jmp     start_kb_get

:
; -------------------------------------------------
; up
        cmp     #FNK_UP
        beq     do_up
        cmp     #FNK_UP2
        beq     do_up
        bne     :+

do_up:
        lda     current_line
        cmp     #0
        beq     cont_kb
        dec     current_line
        jsr     save_current_line
        jsr     _fn_highlight_line
        jmp     start_kb_get

:
; -------------------------------------------------
; down
        cmp     #FNK_DOWN
        beq     do_down
        cmp     #FNK_DOWN2
        beq     do_down
        bne     :+

do_down:
        lda     current_line
        cmp     selected_max
        bcs     cont_kb
        inc     current_line
        jsr     save_current_line
        jsr     _fn_highlight_line
        jmp     start_kb_get

:
; may need to move this to middle of the cases so they can branch to it easily, or change to jmps
cont_kb:
        ; and reloop if we didn't leave this routine through a kb option
        jmp     start_kb_get


do_kb_module:
        jmp     (kb_mod_proc)
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
kb_mod_proc:    .res 2
selected_max:   .res 1
next_mod:       .res 1
prev_mod:       .res 1
