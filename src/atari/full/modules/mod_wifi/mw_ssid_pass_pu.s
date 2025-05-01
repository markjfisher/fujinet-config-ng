		.export     mw_ssid_pass_pu

        .import     show_select
        .import     ss_args
        .import     fuji_netconfig
        .import     mw_ask_custom_wifi_pass_info
        .import     mw_ask_custom_wifi_pu_msg
        .import     mw_ask_custom_wifi_ssid_info
        .import     mw_ask_cutom_wifi_info
        .import     mw_help
        .import     mw_save_ssid
        .import     _just_rts
        .import     pushax
        .import     return1

        .import     debug

        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "macros.inc"
        .include    "popup.inc"

.proc mw_ssid_pass_pu

        ; our current fuji_netconfig struct can be used to hold the data being edited, no malloc needed
        mwa     {#(fuji_netconfig + NetConfig::ssid)}, { mw_ask_custom_wifi_ssid_info + POPUP_VAL_IDX }
        mwa     {#(fuji_netconfig + NetConfig::password)}, { mw_ask_custom_wifi_pass_info + POPUP_VAL_IDX }

        mwa     #_just_rts, ss_args+ShowSelectArgs::kb_cb
        mwa     #mw_ask_cutom_wifi_info, ss_args+ShowSelectArgs::items
        mwa     #mw_help, ss_args+ShowSelectArgs::help_cb
        mwa     #mw_ask_custom_wifi_pu_msg, ss_args+ShowSelectArgs::message

        jsr     show_select

        cpx     #PopupItemReturn::escape
        beq     esc_bssid

        ; details accepted, try them
        jmp     mw_save_ssid

esc_bssid:
        jmp     return1

.endproc