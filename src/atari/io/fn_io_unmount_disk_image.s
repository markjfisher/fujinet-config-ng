        .export     _fn_io_unmount_disk_image

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "../inc/dcb.inc"
        .import     _fn_io_copy_dcb

; void _fn_io_unmount_disk_image(uint8 slot)
.proc _fn_io_unmount_disk_image
        sta     tmp1    ; save slot

        setax   #t_io_unmount_disk_image
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        jmp     SIOV
.endproc

.rodata
t_io_unmount_disk_image:
        .byte $e9, $00, $00, $00, $0f, $00, $00, $00, $ff, $00