.enum   IO_FN
        get_wifi_enabled
        get_wifi_status
        get_ssid
        set_ssid
        scan_for_networks
        get_scan_result
        get_adapter_config
        get_device_slots
        put_device_slots
.endenum

; Not currently used
.struct IO_DCB
    .org $0300
    ddevic  .byte
    dunit   .byte
    dcomnd  .byte
    dstats  .byte
    dbuflo  .byte
    dbufhi  .byte
    dtimlo  .byte
    dunuse  .byte
    dbytlo  .byte
    dbythi  .byte
    daux1   .byte
    daux2   .byte
.endstruct

.struct NetConfig
    ssid        .res 33  ; 32 + NULL
    password    .res 64
.endstruct

.struct SSIDInfo
    ssid        .res 33  ; 32 + NULL
    rssi        .res 1
.endstruct

.struct AdapterConfig
    ssid        .res 33
    hostname    .res 64
    localIP     .res 4
    gateway     .res 4
    netmask     .res 4
    dnsIP       .res 4
    macAddress  .res 6
    bssid       .res 6
    fn_version  .res 15
.endstruct

.struct DeviceSlot
    hostSlot    .res 1
    mode        .res 1
    file        .res 36
.endstruct

.struct HostSlot
    data        .res 32
.endstruct
