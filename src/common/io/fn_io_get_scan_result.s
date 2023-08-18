        .export         _fn_io_get_scan_result
        .import         _fn_io_copy_dcb, _fn_io_dosiov
        .import         popa

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "fn_data.inc"

; void _fn_io_get_scan_result(uint8 network_index, void *SSIDInfo)
;
; caller must supply memory location for ssidinfo to go
.proc _fn_io_get_scan_result
        getax   ssidinfo_location       ; location to put ssidinfo into
        popa    tmp1                    ; save index

        setax   #t_io_get_scan_result
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        mwa     ssidinfo_location, IO_DCB::dbuflo
        jmp     _fn_io_dosiov
.endproc

.rodata
.define SIsz .sizeof(SSIDInfo)

t_io_get_scan_result:
        .byte $fc, $40, $ff, $ff, $0f, $00, <SIsz, >SIsz, $ff, $00

.bss
ssidinfo_location:      .res 2
