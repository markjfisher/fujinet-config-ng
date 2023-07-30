        .export         _fn_io_get_wifi_status
        .import         _fn_io_siov
        .include        "../inc/macros.inc"
        .include        "fn_io.inc"

; int _fn_io_get_wifi_status()
;
; Return values are:
;  1: No SSID available
;  3: Connection Successful
;  4: Connect Failed
;  5: Connection lost
.proc _fn_io_get_wifi_status
        setax   #fn_t_io_get_wifi_status
        jsr     _fn_io_siov

        lda     fn_io_wifi_status
        ldx     #$00
        rts
.endproc

.rodata
fn_t_io_get_wifi_status:
        .byte $fa, $40, <fn_io_wifi_status, >fn_io_wifi_status, $0f, $00, $01, $00, $00, $00

.bss
fn_io_wifi_status: .res 1