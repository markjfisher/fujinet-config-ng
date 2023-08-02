        .export         _fn_io_set_ssid
        .import         _fn_io_siov, fn_io_net_config
        .include        "fn_macros.inc"
        .include        "fn_io.inc"

; void  _fn_io_set_ssid()
; sends the ssid to sio.
.proc _fn_io_set_ssid
        setax   #t_io_set_ssid
        jmp     _fn_io_siov
.endproc

.rodata
.define NCsz .sizeof(NetConfig)

t_io_set_ssid:
        .byte $fb, $80, <fn_io_net_config,     >fn_io_net_config,     $0f, $00, <NCsz, >NCsz, $01, $00
