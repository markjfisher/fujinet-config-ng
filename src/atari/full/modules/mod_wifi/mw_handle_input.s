        .export     _mw_handle_input

        .import     _kb_global
        .import     _scr_clr_highlight
        .import     _scr_highlight_line
        .import     kb_current_line
        .import     kb_max_entries
        .import     mh_host_selected
        .import     mw_net_count
        .import     mw_selected
        .import     mw_setting_up
        .import     mw_setup_wifi
        .import     pusha
        .import     pushax
        .import     debug

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

.proc _mw_handle_input
        jsr     _scr_clr_highlight

        pusha   #0
        pusha   #Mod::devices   ; prev
        pusha   #Mod::done      ; next
        pushax  #mw_selected    ; memory address of our current host so it can be updated
        setax   #mw_kb_handler  ; hosts kb handler
        jmp     _kb_global      ; rts from this will drop out of module

.endproc

.proc mw_kb_handler
        ; A - contains key code, always in upper case if ascii

; --------------------------------------------------
; S - setup wifi
        cmp     #'S'
        bne     not_setup

        lda     mw_setting_up
        bne     not_setup               ; already setting up, ignore. allows us to reuse this same kbh for all wifi setup actions

        mva     #$01, mw_setting_up

        ; TODO: popup while we are scanning networks
        jsr     mw_setup_wifi

        ; highlight the first entry
        mva     mw_net_count, kb_max_entries
        jsr     _scr_highlight_line

        ; we're still on this mod, just reloop, the kbh adapts to if we're in setup mode or not
        ldx     #KBH::RELOOP
        rts

not_setup:

; --------------------------------------------------
; ESC - exit setup wifi
        cmp     #FNK_ESC
        bne     not_esc

        mva     #$00, mw_setting_up
        sta     kb_max_entries
        jsr     _scr_clr_highlight
        ldx     #KBH::EXIT
        rts

not_esc:

; --------------------------------------------------
; LEFT or RIGHT
        cmp     #FNK_LEFT
        beq     is_lr
        cmp     #FNK_LEFT2
        beq     is_lr
        cmp     #FNK_RIGHT
        beq     is_lr
        cmp     #FNK_RIGHT2
        bne     not_lr

is_lr:
        ; need to keep keycode in A, hence why using X here
        ldx     mw_setting_up           ; ignore if we're not in setup mode
        beq     out

        ; pretend we handled it, and reloop on kbh. this will stop us moving off the current screen
        ldx     #KBH::RELOOP
        rts

not_lr:

; --------------------------------------------------
; ENTER - select the current highlighted line and act on it
        cmp     #FNK_ENTER
        bne     not_enter

        ldx     mw_setting_up
        beq     out                     ; ignore if we're not in setup mode

        ; if the highlight is 0-(max-2), the user picked from list, otherwise they are on the 'custom' option



not_enter:

; ----------------------------------------------------------------------
; EXIT - didn't handle it - put in the middle so branching can reach
; ----------------------------------------------------------------------
out:
        ldx     #KBH::NOT_HANDLED
        rts



.endproc
