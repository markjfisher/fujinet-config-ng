; io_mem.s
;
; buffers etc for io

        .export io_wifi_enabled, io_wifi_status
        .export io_net_config, io_scan, io_ssidinfo, io_buffer

        .include "io.inc"

; TODO: should this be BSS?
.data

io_wifi_enabled: .res 1
io_wifi_status:  .res 1
io_scan:         .res 4
io_net_config:   .tag NetConfig
io_ssidinfo:     .tag SSIDInfo
io_buffer:       .res $100