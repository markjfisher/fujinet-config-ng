; io_get_scan_result.s
;

        .export         io_get_scan_result
        .import         io_copy_dcb, io_ssidinfo
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; SSIDInfo* io_get_scan_result(network_index)
.proc io_get_scan_result
        pha     ; save index - avoiding SMC so we can go ROM later... maybe?

        ldx #IO_FN::get_scan_result
        jsr io_copy_dcb

        ; override network index to scan
        pla
        sta IO_DCB::daux1
        jsr SIOV

        ; set return into A/X
        setax #io_ssidinfo

        rts
.endproc
