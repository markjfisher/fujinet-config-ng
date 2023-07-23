.enum   IO_FN
        get_wifi_enabled
        get_wifi_status
        get_ssid
.endenum

.struct NetConfig
    ssid        .res 33  ; 32 + NULL
    password    .res 64
.endstruct
