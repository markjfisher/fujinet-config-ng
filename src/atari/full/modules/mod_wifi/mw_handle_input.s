        .export     _mw_handle_input

        .import     _kb_global
        .import     _edit_line
        .import     _mw_display_wifi
        .import     _mw_init_screen
        .import     _put_s
        .import     _scr_clr_highlight
        .import     _scr_highlight_line
        .import     fn_io_netconfig
        .import     get_scrloc
        .import     kb_current_line
        .import     kb_max_entries
        .import     mw_do_setup
        .import     mw_fetching_nets
        .import     mh_host_selected
        .import     mw_net_count
        .import     mw_nets_msg
        .import     mw_selected
        .import     mw_setting_up
        .import     mw_setup_wifi
        .import     pusha
        .import     pushax
        .import     put_s_p1p4
        .import     debug

        .include    "zeropage.inc"
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
        ldx     #KBH::EXIT              ; end kbh mode, which will reload page.
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
; EXIT - finish processing and reload page
; ----------------------------------------------------------------------
exit:
        ldx     #KBH::EXIT
        rts

; ----------------------------------------------------------------------
; NOT HANDLED - didn't handle key press, let global handler try
; ----------------------------------------------------------------------
not_handled:
        ldx     #KBH::NOT_HANDLED
        rts

not_lr:
; --------------------------------------------------
; ENTER - select the current highlighted line and act on it
        cmp     #FNK_ENTER
        bne     not_handled

        ldx     mw_setting_up
        beq     not_handled             ; ignore if we're not in setup mode

        ; TODO: SHOW CUSTOM HELP FOR PICKING


        ; if the highlight is 0 to mw_net_count-1, the user picked from list, otherwise they are on the 'custom' option
        ; mw_selected vs mw_net_count
        lda     mw_selected
        cmp     mw_net_count
        bcc     existing_net

        ; custom option, replace the text with blank, and allow them to edit at this point
        ; TODO: SHOW CUSTOM HELP FOR ENTERING DETAILS

        ldx     #$00
        lda     mw_selected
        clc
        adc     #9                      ; adjust for top section
        tay
        jsr     get_scrloc              ; ptr4 = edit location

        ; string location is fn_io_netconfig::ssid
        ; first print it to screen if it's got a value, to allow user to continue editing previous value

        mwa     {#(fn_io_netconfig + NetConfig::ssid)}, ptr1
        jsr     put_s_p1p4

        ; -----------------------------------------------------------------
        ; BSSID
        pushax  ptr1
        pushax  ptr4
        lda     #32
        jsr     _edit_line

        ; return value = 1 for changed, 0 for ESC
        beq     esc_new_bssid

        ; a host name was provided, now need a password, use next line. print any value we have in our NetConfig mem
        adw1    ptr4, #SCR_BYTES_W
        mwa     {#(fn_io_netconfig + NetConfig::password)}, ptr1
        jsr     put_s_p1p4

        ; -----------------------------------------------------------------
        ; PASSWORD
        pushax  ptr1
        pushax  ptr4
        lda     #64                     ; TODO: make the edit field cope with long strings on screen. this will trash borders
        jsr     _edit_line
        beq     esc_new_bssid

        ; we set both, so save them back to FN
        ; TODO

        ; now exit, everything done.
        jmp     exit

existing_net:
        ; TODO: convert from selection to something we save
        jmp     exit

esc_new_bssid:
        ; reset screen, put us back into showing the list of wifis
        jsr     _mw_init_screen
        jsr     _mw_display_wifi
        jmp     mw_do_setup

.endproc
