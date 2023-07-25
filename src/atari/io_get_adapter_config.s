        .export         io_get_adapter_config, io_adapter_config
        .import         io_siov, pushax
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; SSIDInfo* io_get_scan_result(network_index)
.proc io_get_adapter_config
        pushax #t_io_get_adapter_config
        jsr io_siov

        setax #io_adapter_config
        rts
.endproc

.data
.define ACsz .sizeof(AdapterConfig)

t_io_get_adapter_config:
        .byte $e8, $40, <io_adapter_config, >io_adapter_config, $0f, $00, <ACsz, >ACsz, $00, $00

.bss
io_adapter_config: .tag AdapterConfig
