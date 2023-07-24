; io_set_ssid.s
;

        .export         io_set_ssid
        .import         io_siov
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; sends the ssid to sio.
.proc io_set_ssid
        ldx #IO_FN::set_ssid
        jmp io_siov
.endproc
