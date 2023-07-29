        .export         io_set_ssid
        .import         io_siov, io_net_config
        .include        "../inc/macros.inc"
        .include        "io.inc"

; void  io_set_ssid()
; sends the ssid to sio.
.proc io_set_ssid
        setax   #t_io_set_ssid
        jmp     io_siov
.endproc

.data

.define NCsz .sizeof(NetConfig)

t_io_set_ssid:
        .byte $fb, $80, <io_net_config,     >io_net_config,     $0f, $00, <NCsz, >NCsz, $01, $00
