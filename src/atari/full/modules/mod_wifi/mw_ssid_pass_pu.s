		.export     mw_ssid_pass_pu

        .import     _show_select
        .import     fuji_netconfig
        .import     mw_ask_custom_wifi_pass_info
        .import     mw_ask_custom_wifi_pu_msg
        .import     mw_ask_custom_wifi_ssid_info
        .import     mw_ask_cutom_wifi_info
        .import     mw_help
        .import     mw_save_ssid
        .import     pu_null_cb
        .import     pushax
        .import     return1

        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "macros.inc"
        .include    "popup.inc"

.proc mw_ssid_pass_pu

        ; our current fuji_netconfig struct can be used to hold the data being edited, no malloc needed
        mwa     {#(fuji_netconfig + NetConfig::ssid)}, { mw_ask_custom_wifi_ssid_info + POPUP_VAL_IDX }
        mwa     {#(fuji_netconfig + NetConfig::password)}, { mw_ask_custom_wifi_pass_info + POPUP_VAL_IDX }

        pushax  #pu_null_cb
        pushax  #mw_ask_cutom_wifi_info
        pushax  #mw_help
        setax   #mw_ask_custom_wifi_pu_msg
        jsr     _show_select

        cmp     #PopupItemReturn::escape
        beq     esc_bssid

        ; details accepted, try them
        jmp     mw_save_ssid

esc_bssid:
        jmp     return1

.endproc