        .export     mw_adapter_config
        .export     mw_is_ac_data_fetched
        .export     mw_net_count
        .export     mw_selected
        .export     mw_setting_up

        .include    "fujinet-fuji.inc"

.bss
; wifi AdapterConfig info. this can't be malloc'd else we'd need to fetch it every time we wizz by the wifi screen
mw_adapter_config:      .tag AdapterConfigExtended
mw_net_count:           .res 4  ; scan returns 4 bytes, only 1 is currently used though. But must have 4 byte buffer, else the following bytes are overwritten
mw_setting_up:          .res 1


.data
; flag to decide if we need to fetch AdapterConfig data. User must be able to refresh
mw_is_ac_data_fetched:  .byte 0

; currently selected wifi entry
mw_selected:            .byte 0
