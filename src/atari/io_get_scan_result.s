        .export         io_get_scan_result, io_ssidinfo
        .import         io_copy_dcb
        .importzp       tmp1
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; SSIDInfo* io_get_scan_result(network_index)
.proc io_get_scan_result
        sta     tmp1        ; save index

        setax   #t_io_get_scan_result
        jsr     io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jsr     SIOV

        ; set return into A/X
        setax   #io_ssidinfo

        rts
.endproc

.data
.define SIsz .sizeof(SSIDInfo)

t_io_get_scan_result:
        .byte $fc, $40, <io_ssidinfo, >io_ssidinfo, $0f, $00, <SIsz, >SIsz, $ff, $00

.bss
io_ssidinfo:       .tag SSIDInfo
