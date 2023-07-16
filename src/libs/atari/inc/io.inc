.struct NetConfig
    ssid        :33 .byte  ; 32 + NULL
    password    :64 .byte
.ends

.struct SSIDInfo
    ssid        :33 .byte  ; 32 + NULL
    rssi            .byte
.ends

.struct AdapterConfig
    ssid        :33 .byte  ; 32 + NULL
    hostname    :64 .byte
    localIP     :4  .byte
    gateway     :4  .byte
    netmask     :4  .byte
    dnsIP       :4  .byte
    macAddress  :6  .byte
    bssid       :6  .byte
    fn_version  :15 .byte
.ends

.struct DeviceSlot
    hostSlot        .byte
    mode            .byte
    file        :33 .byte
.ends

.struct HostSlot
    data        :32 .byte
.ends
