        .export     mw_adapter_config
        .export     mw_is_ac_data_fetched
        .export     mw_selected

        .include    "fn_io.inc"

.bss
; wifi AdapterConfig info. this can't be malloc'd else we'd need to fetch it every time we wizz by the wifi screen
mw_adapter_config:      .tag AdapterConfigExtended


.data
; flag to decide if we need to fetch AdapterConfig data. User must be able to refresh
mw_is_ac_data_fetched:  .byte 0

mw_selected:            .byte 0
