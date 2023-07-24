; io_mem.s
;
; buffers etc for io

        .export io_wifi_enabled, io_wifi_status
        .export io_net_config, io_scan, io_ssidinfo, io_adapter_config, io_buffer

        .include "io.inc"

; TODO: should this be BSS?
; TODO: Can we convert to malloc? The addresses would need to be put into the tables dynamically
.data

io_wifi_enabled:   .res 1
io_wifi_status:    .res 1
io_scan:           .res 4
io_net_config:     .tag NetConfig
io_ssidinfo:       .tag SSIDInfo
io_adapter_config: .tag AdapterConfig
io_buffer:         .res $100
