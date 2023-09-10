        .export     mw_adapter_config
        .export     mw_is_ac_data_fetched
        .export     mw_net_count
        .export     mw_selected
        .export     mw_setting_up

        .include    "fn_io.inc"

.bss
; wifi AdapterConfig info. this can't be malloc'd else we'd need to fetch it every time we wizz by the wifi screen
mw_adapter_config:      .tag AdapterConfigExtended
mw_net_count:           .res 1
mw_setting_up:          .res 1


.data
; flag to decide if we need to fetch AdapterConfig data. User must be able to refresh
mw_is_ac_data_fetched:  .byte 0

; currently selected wifi entry
mw_selected:            .byte 0
