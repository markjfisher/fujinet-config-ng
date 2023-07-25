        .export         io_scan_for_networks, io_scan
        .import         io_siov, pushax
        .include        "../inc/macros.inc"

; int io_scan_for_netwroks()
;
; returns count of networks scanned
.proc io_scan_for_networks
        pushax #t_io_scan_for_networks
        jsr io_siov

        lda io_scan
        rts
.endproc

.data

t_io_scan_for_networks:
        .byte $fd, $40, <io_scan, >io_scan, $0f, $00, $04, $00, $00, $00

.bss
io_scan:           .res 4
