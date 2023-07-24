; io_mem.s
;
; buffers etc for io

        .export io_wifi_enabled, io_wifi_status
        .export io_net_config, io_scan, io_ssidinfo, io_adapter_config
        .export io_deviceslots, io_hostslots, io_buffer

        .include "io.inc"

.bss

io_wifi_enabled:   .res 1
io_wifi_status:    .res 1
io_scan:           .res 4
io_net_config:     .tag NetConfig
io_ssidinfo:       .tag SSIDInfo
io_adapter_config: .tag AdapterConfig
io_deviceslots:    .res 8 * .sizeof(DeviceSlot)
io_hostslots:      .res 8 * .sizeof(HostSlot)
io_buffer:         .res $100
