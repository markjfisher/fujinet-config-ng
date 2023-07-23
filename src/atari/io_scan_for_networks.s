; io_set_ssid.s
;

        .export         io_scan_for_networks
        .import         io_siov, io_buffer, io_scan
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; sends the ssid to sio.
.proc io_scan_for_networks
        ldx #IO_FN::scan_for_networks
        jsr io_siov

        lda io_scan
        rts
.endproc
