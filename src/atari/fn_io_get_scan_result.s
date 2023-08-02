        .export         _fn_io_get_scan_result, fn_io_ssidinfo
        .import         _fn_io_copy_dcb
        .include        "zeropage.inc"
        .include        "atari.inc"
        .include        "fn_macros.inc"
        .include        "fn_io.inc"

; SSIDInfo* _fn_io_get_scan_result(network_index)
.proc _fn_io_get_scan_result
        sta     tmp1        ; save index

        setax   #t_io_get_scan_result
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jsr     SIOV

        ; set return into A/X
        setax   #fn_io_ssidinfo

        rts
.endproc

.rodata
.define SIsz .sizeof(SSIDInfo)

t_io_get_scan_result:
        .byte $fc, $40, <fn_io_ssidinfo, >fn_io_ssidinfo, $0f, $00, <SIsz, >SIsz, $ff, $00

.bss
fn_io_ssidinfo:       .tag SSIDInfo
