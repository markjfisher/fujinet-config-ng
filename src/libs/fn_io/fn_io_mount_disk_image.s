        .export     _fn_io_mount_disk_image
        .import     fn_io_copy_dcb, popa, _fn_io_dosiov

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; void fn_io_mount_disk_image(uint8_t slot, uint8_t mode)
.proc _fn_io_mount_disk_image
        sta     tmp1    ; save mode
        popa    tmp2    ; save slot

        setax   #t_io_mount_disk_image
        jsr     fn_io_copy_dcb

        mva     tmp2, IO_DCB::daux1
        mva     tmp1, IO_DCB::daux2
        jmp     _fn_io_dosiov
.endproc

.rodata
t_io_mount_disk_image:
        .byte $f8, $00, $00, $00, $fe, $00, $00, $00, $ff, $ff