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

.struct NewDisk
    numSectors  .res 2
    sectorSize  .res 2
    hostSlot    .res 1
    deviceSlot  .res 1
    filename    .res $e0    ; same size as fn_dir_path
.endstruct

; these are word offsets, save ourselves a LSR and pre-double them
.enum DiskSize
    size90      = 0
    size130     = 2
    size180     = 4
    size360     = 6
    size720     = 8
    size1440    = 10
    sizeCustom  = 12
.endenum

.enum WifiStatus
    no_ssid_available   = 1
    connected           = 3
    connect_failed      = 4
    connection_lost     = 5
.endenum
