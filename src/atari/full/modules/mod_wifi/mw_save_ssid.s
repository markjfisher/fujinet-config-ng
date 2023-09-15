        .export mw_save_ssid

        .import     _fn_io_get_wifi_status
        .import     _fn_io_set_ssid
        .import     _mw_init_screen
        .import     _pause
        .import     _put_s
        .import     _scr_clr_highlight
        .import     fc_connected
        .import     fn_io_netconfig
        .import     mw_error_connecting
        .import     mw_is_ac_data_fetched
        .import     mw_nets_msg
        .import     pusha
        .import     return0
        .import     return1

        .import     debug

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "fc_mods.inc"

.proc mw_save_ssid
        setax   #fn_io_netconfig
        jsr     _fn_io_set_ssid

        ; mark we haven't got the data, so when we reload the page, it's refreshed
        mva     #$00, mw_is_ac_data_fetched
        jsr     _mw_init_screen

        jsr     _scr_clr_highlight      ; turn off the PMG highlight
        put_s   #10, #12, #mw_nets_msg  ; print "fetching" message that ill be erased when we start printing results

        lda     #$02                    ; Give the FN time to connect - NOT NEEDED NOW
        jsr     _pause

        ; check connection status
        jsr     _fn_io_get_wifi_status
        cmp     #WifiStatus::connected
        bne     err_status
        mva     #$01, fc_connected
        jmp     return0

        ; display an error that the connection didn't work
err_status:
        mva     #$00, mw_is_ac_data_fetched
        sta     fc_connected
        jsr     mw_error_connecting
        jmp     return1

.endproc