        .export         _fn_io_get_wifi_status
        .import         _fn_io_siov

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_io.inc"

; int _fn_io_get_wifi_status()
;
; Return values are:
;  1: No SSID available
;  3: Connection Successful
;  4: Connect Failed
;  5: Connection lost
.proc _fn_io_get_wifi_status
        setax   #t_io_get_wifi_status
        jsr     _fn_io_siov

        lda     tmp1
        ldx     #$00
        rts
.endproc

.rodata
t_io_get_wifi_status:
        .byte $fa, $40, <tmp1, >tmp1, $0f, $00, $01, $00, $00, $00