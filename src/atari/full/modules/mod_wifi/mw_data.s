        .export     mw_adapter_config
        .export     mw_is_ac_data_fetched
        .export     mw_net_count
        .export     mw_selected
        .export     mw_setting_up
        .export     mw_ask_custom_wifi_pass_info
        .export     mw_ask_custom_wifi_pu_msg
        .export     mw_ask_custom_wifi_ssid_info
        .export     mw_ask_cutom_wifi_info

        .include    "fujinet-fuji.inc"
        .include    "popup.inc"

.bss
; wifi AdapterConfig info. this can't be malloc'd else we'd need to fetch it every time we wizz by the wifi screen
mw_net_count:           .res 4  ; scan returns 4 bytes, only 1 is currently used though. But must have 4 byte buffer, else the following bytes are overwritten
mw_setting_up:          .res 1

.segment "BANK"
mw_adapter_config:      .tag AdapterConfigExtended

.data
; flag to decide if we need to fetch AdapterConfig data. User must be able to refresh
mw_is_ac_data_fetched:  .byte 0

; currently selected wifi entry
mw_selected:            .byte 0

mw_ask_custom_wifi_pu_msg:
                        .byte "Set SSID/Pass", 0

mw_ask_custom_wifi_ssid_msg:
                        .byte "SSID: ", 0
mw_ask_custom_wifi_pass_msg:
                        .byte "Pass: ", 0

mw_ask_cutom_wifi_info:
                        .byte 30, 1, 1, $ff, $ff, 0

mw_ask_custom_wifi_ssid_info:
                        .byte PopupItemType::string, 1, 32, $ff, $ff, 18, <mw_ask_custom_wifi_ssid_msg, > mw_ask_custom_wifi_ssid_msg

                        .byte PopupItemType::space

mw_ask_custom_wifi_pass_info:
                        .byte PopupItemType::password, 1, 64, $ff, $ff, 18, <mw_ask_custom_wifi_pass_msg, > mw_ask_custom_wifi_pass_msg

                        .byte PopupItemType::space
                        .byte PopupItemType::finish

