        .export         _fn_io_scan_for_networks, fn_io_scan
        .import         _fn_io_siov
        .include        "../inc/macros.inc"

; int _fn_io_scan_for_netwroks()
;
; returns count of networks scanned
.proc _fn_io_scan_for_networks
        setax   #fn_t_io_scan_for_networks
        jsr     _fn_io_siov

        lda     fn_io_scan
        ldx     #$00
        rts
.endproc

.rodata
fn_t_io_scan_for_networks:
        .byte $fd, $40, <fn_io_scan, >fn_io_scan, $0f, $00, $04, $00, $00, $00

.bss
fn_io_scan:           .res 4
