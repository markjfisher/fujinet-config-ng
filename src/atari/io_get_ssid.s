; io_get_ssid.s
;

        .export         io_get_ssid
        .import         io_siov, io_net_config
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; read ssid to io_net_config and return its address via A/X
.proc io_get_ssid
        ldx #IO_FN::get_ssid
        jsr io_siov

        setax #io_net_config
        rts
.endproc
