; io_get_ssid.s
;

        .export         io_get_ssid, net_config
        .import         io_siov
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; get ssid into net_config and return its address via A/X
.proc io_get_ssid
        ldx #IO_FN::get_ssid
        jsr io_siov

        _setax #net_config
        rts
.endproc

; ------------------------------------------------------

.data
net_config:   .tag NetConfig
