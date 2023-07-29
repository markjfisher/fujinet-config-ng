        .export         io_scan_for_networks, io_scan
        .import         io_siov
        .include        "../inc/macros.inc"

; int io_scan_for_netwroks()
;
; returns count of networks scanned
.proc io_scan_for_networks
        setax   #t_io_scan_for_networks
        jsr     io_siov

        lda     io_scan
        ldx     #$00
        rts
.endproc

.data

t_io_scan_for_networks:
        .byte $fd, $40, <io_scan, >io_scan, $0f, $00, $04, $00, $00, $00

.bss
io_scan:           .res 4
