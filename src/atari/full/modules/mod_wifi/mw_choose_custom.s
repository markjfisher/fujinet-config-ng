        .export mw_choose_custom

        .import     _clr_help
        .import     _edit_line
        .import     _fc_strncpy
        .import     _fn_io_get_scan_result
        .import     _put_help
        .import     debug
        .import     fn_io_netconfig
        .import     fn_io_ssidinfo
        .import     get_scrloc
        .import     mw_help_custom
        .import     mw_help_password
        .import     mw_save_ssid
        .import     mw_selected
        .import     pusha
        .import     pushax
        .import     put_s_p1p4
        .import     return1

        .include    "fc_zp.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

.proc mw_choose_custom
        jsr     _clr_help
        put_help   #0, #mw_help_custom

        ldx     #$00
        lda     mw_selected
        clc
        adc     #9                      ; adjust for top section
        tay
        jsr     get_scrloc              ; ptr4 = edit location

        ; blank the line that read "<Enter Custom SSID>"
        lda     #$00            ; we know this is screen for space, conveniently 0 for setting y
        tay
:       sta     (ptr4), y
        iny
        cpy     #38
        bne     :-

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
        beq     esc_bssid

        ; a host name was provided, now need a password, use next line. print any value we have in our NetConfig mem
        jsr     _clr_help
        put_help   #0, #mw_help_password

        adw1    ptr4, #SCR_BYTES_W
        mwa     {#(fn_io_netconfig + NetConfig::password)}, ptr1
        jsr     put_s_p1p4

        ; -----------------------------------------------------------------
        ; PASSWORD
        pushax  ptr1
        pushax  ptr4
        lda     #64                     ; TODO: make the edit field cope with long strings on screen. this will trash borders
        jsr     _edit_line
        beq     esc_bssid

        ; we set both, so save them back to FN
        jmp     mw_save_ssid

esc_bssid:
        jmp     return1

.endproc