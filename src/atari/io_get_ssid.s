        .export         io_get_ssid
        .import         io_siov, io_net_config
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; NetConfig* io_get_netconfig()
;
; read ssid to io_net_config and return its address via A/X
.proc io_get_ssid
        setax   #t_io_get_ssid
        jsr     io_siov

        setax   #io_net_config
        rts
.endproc

.rodata
.define NCsz .sizeof(NetConfig)

t_io_get_ssid:
        .byte $fe, $40, <io_net_config,     >io_net_config,     $0f, $00, <NCsz, >NCsz, $00, $00
