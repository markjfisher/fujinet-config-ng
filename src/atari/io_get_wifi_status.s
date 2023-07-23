; io_get_wifi_status.s
;

        .export         io_get_wifi_status
        .import         io_siov, io_wifi_status
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; Return values are:
;  1: No SSID available
;  3: Connection Successful
;  4: Connect Failed
;  5: Connection lost
.proc io_get_wifi_status
        ldx #IO_FN::get_wifi_status
        jsr io_siov

        lda io_wifi_status
        rts
.endproc
