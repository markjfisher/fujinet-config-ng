        .export mw_save_ssid

        .import     _fuji_get_wifi_status
        .import     _fuji_set_ssid
        .import     _mw_init_screen
        .import     _put_s
        .import     _scr_clr_highlight
        .import     fc_connected
        .import     fuji_netconfig
        .import     mw_error_connecting
        .import     mw_is_ac_data_fetched
        .import     mw_nets_msg
        .import     pusha
        .import     return0
        .import     return1

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "modules.inc"

.proc mw_save_ssid
        setax   #fuji_netconfig
        jsr     _fuji_set_ssid

        ; mark we haven't got the data, so when we reload the page, it's refreshed
        mva     #$00, mw_is_ac_data_fetched
        jsr     _mw_init_screen

        jsr     _scr_clr_highlight      ; turn off the PMG highlight
        put_s   #10, #12, #mw_nets_msg  ; print "fetching" message that will be erased when we start printing results

        ; check connection status, use tmp1/2 as the location for the results
        setax   #tmp1
        jsr     _fuji_get_wifi_status
        lda     tmp1
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