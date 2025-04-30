        .export     kb_global

        .export     kb_current_line
        .export     kb_max_entries
        .export     kb_prev_mod
        .export     kb_next_mod
        .export     kb_mod_current_line_p
        .export     kb_mod_proc
        .export     kb_idle_counter

        .import     _clr_scr_all
        .import     _clr_status
        .import     _kb_get_c_ucase
        .import     _kb_is_option
        .import     _scr_highlight_line
        .import     booting_mode
        .import     joy_process
        .import     mf_copying
        .import     mod_current
        .import     mx_ask_lobby

        .import     debug
        .import     _pause

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "fn_data.inc"

.segment "CODE2"

;  kb_max_entries:  Total entries on page - 1, for up/down movement
;         prevmod:  which mod to go to if press left key
;         nextmod:  which mod to go to if press right key
; kb_current_line:  the mod specific location to store the current selected line (zero based) so each mod can return to where it was
;     kb_mod_proc:  the module specific keyboard routine to check current keypress for. e.g. pressing enter is mod specific
;
; A global keyboard handler for navigation on modules. Passes off to mod specific kb handler first to allow it to be processed locally.
; then deals with common cases (L/R, U/D, Option, ... more TODO)

.proc kb_global
        jmp     save_state
        ; implicit rts

start_kb_get:

        ; check for option to boot
        jsr     _kb_is_option
        beq     not_option

        ; set exit module with a flag to say boot
        mva     #ExitMode::boot, booting_mode
        mva     #Mod::boot, mod_current
        ldx     #KBH::EXIT
        rts

not_option:
        jsr     joy_process
        cmp     #$00
        bne     some_input
        jsr     _kb_get_c_ucase
        cmp     #$00
        bne     some_input

        ; check idle counter, when it hits a level, run a callback function to allow
        ; code to do some animation etc.

        ; is there even a cb setup?
        lda     kb_cb_function
        ora     kb_cb_function+1
        beq     start_kb_get

        lda     kb_idle_counter
        cmp     #120                    ; have we had roughly 2 seconds for initial trigger, or reached re-trigger?
        bcc     start_kb_get            ; not yet

        ; we hit max either for first time after key press, or after an animation frame, so run cb again
        lda     #108                    ; reset to this so we only wait a shorter period for next animation, 120-108 = 12 = 0.2s
        sta     kb_idle_counter

        ; do the cb
        bne     do_kb_cb

; ----------------------------------------------------------
; KEYBOARD HANDLING SWITCH STATEMENT
; ----------------------------------------------------------

some_input:
        ldx     #$00
        stx     kb_idle_counter         ; reset counter after any input
        ldx     #KBH::NOT_HANDLED       ; status of module keyboard handler set in x on return

        ; use module specific keyboard handler first, so we can override default handling, e.g. L/R arrow keys may not move modules
        jsr     do_kb_module

        ; if X=NOT_HANDLED, then we use global kb handler, as key wasn't processed, A is still keycode
        cpx     #KBH::NOT_HANDLED
        beq     global_kb

        cpx     #KBH::RELOOP
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
        mva     kb_next_mod, mod_current
        rts

; ---------------------------------------------------
; placed to be reachable by branches
save_state:
        ldy     #$00
        mwa     kb_mod_current_line_p, ptr1
        mva     kb_current_line, {(ptr1), y}

        ; only highlight line if there are any to highlight
        lda     kb_max_entries
        beq     cont_kb
        jsr     _scr_highlight_line
        ; jmp     cont_kb

cont_kb:
        clc
        bcc     start_kb_get

; also placed in middle for branches
do_kb_cb:
        mwa     kb_cb_function, smc
        ; A is high byte of cb_function, which is never in page zero, no never 0 at this point
        bne     do_jmp

; ---------------------------------------------------

:
; -------------------------------------------------
; left - set prev module, and exit kb_global
        cmp     #FNK_LEFT
        beq     do_left
        cmp     #FNK_LEFT2
        beq     do_left
        bne     :+

do_left:
        mva     kb_prev_mod, mod_current
        rts

:
; -------------------------------------------------
; up
        cmp     #FNK_UP
        beq     do_up
        cmp     #FNK_UP2
        beq     do_up
        bne     :+

do_up:
        lda     kb_current_line
        cmp     #0
        beq     cont_kb
        dec     kb_current_line
        ; can't go negative
        bpl     save_state
:
; -------------------------------------------------
; down
        cmp     #FNK_DOWN
        beq     do_down
        cmp     #FNK_DOWN2
        beq     do_down
        bne     not_down

do_down:
        lda     kb_current_line
        cmp     kb_max_entries
        bcs     cont_kb
        inc     kb_current_line
        ; fall through to saving and restarting
        bne     save_state

not_down:
; -------------------------------------------------
; LOBBY
        cmp     #FNK_LOBBY
        bne     not_lobby

        jsr     mx_ask_lobby
        ; return in A is 0 for YES, 1 for NO/escape
        bne     lobby_exit

        ; exit the kb handler, but with the next mode set as Exit, and the mode as booting lobby
        mva     #ExitMode::lobby, booting_mode
        mva     #Mod::boot, mod_current

lobby_exit:
        rts

not_lobby:
; -------------------------------------------------
; X - Exit Copying Mode
        cmp     #FNK_EXITCOPY
        bne     not_x

        mva     #$00, mf_copying
        jsr     _clr_status
        ldx     #KBH::EXIT
        rts

not_x:

; -------------------------------------------------
; Q - Quit application
        cmp     #FNK_QUIT
        bne     not_q

        mva     #Mod::exit, mod_current
        rts

not_q:
;         cmp     #'Z'
;         bne     not_z

;         jsr     _clr_scr_all
;         lda     #$02
;         jsr     _pause
;         jsr     debug

; not_z:

; cont_kb:
;         ; and reloop if we didn't leave this routine through a kb option
;         jmp     start_kb_get

        bne     cont_kb

do_kb_module:
        ; save A, it's needed as parameter to function being called
        tay
        mwa     kb_mod_proc, smc
        tya

do_jmp:
        jmp     $ffff
smc     = *-2

.endproc

.bss
kb_mod_current_line_p:  .res 2
kb_current_line:        .res 1
kb_mod_proc:            .res 2
kb_max_entries:         .res 1
kb_next_mod:            .res 1
kb_prev_mod:            .res 1

.data
kb_cb_function:         .word $0000
kb_idle_counter:        .byte $00
