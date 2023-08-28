        .export         _fn_io_mount_all
        .import         _fn_io_siov

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include         "fn_data.inc"

; uint8_t _fn_io_mount_all(void)
;
; 1 = success, otherwise error
.proc _fn_io_mount_all
        setax   #t_io_mount_all
        jsr     _fn_io_siov

        ldx     #$00
        lda     IO_DCB::dstats
        rts
.endproc

.rodata

t_io_mount_all:
        .byte $d7, $00, $00, $00, $0f, $00, $00, $00, $00, $00
