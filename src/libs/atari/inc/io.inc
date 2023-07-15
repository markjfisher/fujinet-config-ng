NetConfig   .struct
    ssid        :33 .byte  ; 32 + NULL
    password    :64 .byte
.ends

SSIDInfo    .struct
    ssid    :33 .byte  ; 32 + NULL
    rssi        .byte
.ends
