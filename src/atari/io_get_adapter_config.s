; io_get_adapter_config.s
;

        .export         io_get_adapter_config
        .import         io_siov, io_adapter_config
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; SSIDInfo* io_get_scan_result(network_index)
.proc io_get_adapter_config
        pha     ; save index - avoiding SMC so we can go ROM later... maybe?

        ldx #IO_FN::get_adapter_config
        jsr io_siov

        setax #io_adapter_config
        rts
.endproc
