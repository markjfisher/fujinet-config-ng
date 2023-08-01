        .export         _fn_io_get_ssid
        .import         _fn_io_siov, fn_io_net_config
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "fn_io.inc"

; NetConfig* io_get_netconfig()
;
; read ssid to fn_io_net_config and return its address via A/X
.proc _fn_io_get_ssid
        setax   #t_io_get_ssid
        jsr     _fn_io_siov

        setax   #fn_io_net_config
        rts
.endproc

.rodata
.define NCsz .sizeof(NetConfig)

t_io_get_ssid:
        .byte $fe, $40, <fn_io_net_config,     >fn_io_net_config,     $0f, $00, <NCsz, >NCsz, $00, $00
