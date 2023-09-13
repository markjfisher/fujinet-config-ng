        .export     _mw_handle_input

        .import     _kb_global
        .import     _mw_display_wifi
        .import     _mw_init_screen
        .import     _scr_clr_highlight
        .import     kb_current_line
        .import     kb_max_entries
        .import     mw_choose_custom
        .import     mw_choose_network
        .import     mw_do_setup
        .import     mw_net_count
        .import     mw_selected
        .import     mw_setting_up
        .import     pusha
        .import     pushax

        .include    "fc_zp.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

.proc _mw_handle_input
        mva     #$00, mw_setting_up
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

        jmp     mw_do_setup

not_setup:

; --------------------------------------------------
; ESC - exit setup wifi
        cmp     #FNK_ESC
        bne     not_esc

        ; if we're not setting up, don't do anything
        lda     mw_setting_up
        beq     reloop

        mva     #$00, mw_setting_up     ; stop being in setting up mode
        sta     kb_max_entries          ; stop anyone selecting anything on the screen
        sta     kb_current_line         ; set selection to 0, in case next scan has less entries
        jsr     _scr_clr_highlight      ; turn off the PMG highlight
        jmp     exit

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
        ldx     mw_setting_up           ; if we're not in setup mode, don't process this key, so global kbh can move us to next/prev page
        beq     not_handled

        ; pretend we handled it, and reloop on kbh. this will stop us moving off the current screen
        ; FALL THROUGH TO reloop, save us a 'bne reloop'
; ----------------------------------------------------------------------
; RELOOP - handled it - but want to reloop in editing
; ----------------------------------------------------------------------
reloop:
        ldx     #KBH::RELOOP
        rts

; ----------------------------------------------------------------------
; NOT HANDLED - didn't handle key press, let global handler try
; ----------------------------------------------------------------------
not_handled:
        ldx     #KBH::NOT_HANDLED
        rts

esc_bssid:
        ; reset screen, put us back into showing the list of wifis
        jsr     _mw_init_screen
        jsr     _mw_display_wifi
        jmp     mw_do_setup


not_lr:
; --------------------------------------------------
; ENTER - select the current highlighted line and act on it
        cmp     #FNK_ENTER
        bne     not_handled

        ldx     mw_setting_up
        beq     not_handled             ; ignore if we're not in setup mode

        ; if the highlight is 0 to mw_net_count-1, the user picked from list, otherwise they are on the 'custom' option
        lda     mw_selected
        cmp     mw_net_count
        bcs     :+

        ; -----------------------------------------
        ; PICKED FROM NETWORK LIST
        jsr     mw_choose_network
        bne     esc_bssid
        beq     exit

        ; -----------------------------------------
        ; PICKED CUSTOM
:       jsr     mw_choose_custom
        bne     esc_bssid
        ; fall through to exit, we have 0 for all ok and saved, 1 for there was an error, but do we care?

; ----------------------------------------------------------------------
; EXIT - finish processing and reload page
; ----------------------------------------------------------------------
exit:
        ldx     #KBH::EXIT
        rts

.endproc

.segment "SCR_DATA"
err_msg:        .byte "ERROR!", 0