; io_get_wifi_status.s
;

        .export         io_get_wifi_status, wifi_status
        .import         io_siov
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io_fn_indexes.inc"

; Return values are:
;  1: No SSID available
;  3: Connection Successful
;  4: Connect Failed
;  5: Connection lost
.proc io_get_wifi_status
        ldx #IO_FN::get_wifi_status
        jsr io_siov

        lda wifi_status
        rts
.endproc

; ------------------------------------------------------

.data
wifi_status:   .byte 0
