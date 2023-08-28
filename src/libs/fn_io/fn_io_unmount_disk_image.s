        .export     _fn_io_unmount_disk_image
        .import     fn_io_copy_dcb, _fn_io_dosiov

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; void _fn_io_unmount_disk_image(uint8_t device_slot)
.proc _fn_io_unmount_disk_image
        sta     tmp1    ; save device slot

        setax   #t_io_unmount_disk_image
        jsr     fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jmp     _fn_io_dosiov
.endproc

.rodata
t_io_unmount_disk_image:
        .byte $e9, $00, $00, $00, $0f, $00, $00, $00, $ff, $00