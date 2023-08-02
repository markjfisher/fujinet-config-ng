        .export         _fn_io_get_adapter_config, fn_io_adapter_config
        .import         _fn_io_siov
        .include        "atari.inc"
        .include        "fn_macros.inc"
        .include        "fn_io.inc"

; SSIDInfo* _fn_io_get_scan_result(network_index)
.proc _fn_io_get_adapter_config
        setax   #t_io_get_adapter_config
        jsr     _fn_io_siov

        setax   #fn_io_adapter_config
        rts
.endproc

.rodata
.define ACsz .sizeof(AdapterConfig)

t_io_get_adapter_config:
        .byte $e8, $40, <fn_io_adapter_config, >fn_io_adapter_config, $0f, $00, <ACsz, >ACsz, $00, $00

.bss
fn_io_adapter_config: .tag AdapterConfig
