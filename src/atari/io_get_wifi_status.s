        .export         io_get_wifi_status
        .import         io_siov
        .include        "../inc/macros.inc"
        .include        "io.inc"

; int io_get_wifi_status()
;
; Return values are:
;  1: No SSID available
;  3: Connection Successful
;  4: Connect Failed
;  5: Connection lost
.proc io_get_wifi_status
        setax   #t_io_get_wifi_status
        jsr     io_siov

        lda     io_wifi_status
        ldx     #$00
        rts
.endproc

.rodata
t_io_get_wifi_status:
        .byte $fa, $40, <io_wifi_status, >io_wifi_status, $0f, $00, $01, $00, $00, $00

.bss
io_wifi_status: .res 1
