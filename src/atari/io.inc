.enum   IO_FN
        get_wifi_enabled
        get_wifi_status
        get_ssid
        set_ssid
        scan_for_networks
.endenum

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
