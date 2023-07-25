; io_get_scan_result.s
;

        .export         io_get_scan_result
        .import         io_copy_dcb, io_ssidinfo
        .importzp       tmp1
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; SSIDInfo* io_get_scan_result(network_index)
.proc io_get_scan_result
        sta tmp1        ; save index

        ldx #IO_FN::get_scan_result
        jsr io_copy_dcb

        mva tmp1, IO_DCB::daux1
        jsr SIOV

        ; set return into A/X
        setax #io_ssidinfo

        rts
.endproc
