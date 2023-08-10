        .export     _fn_io_mount_disk_image

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_structs.inc"
        .import     _fn_io_copy_dcb, popa

; void fn_io_mount_disk_image(uint8 slot, uint8 mode)
.proc _fn_io_mount_disk_image
        sta     tmp1    ; save mode
        popa    tmp2    ; save slot

        setax   #t_io_mount_disk_image
        jsr     _fn_io_copy_dcb

        mva     tmp2, IO_DCB::daux1
        mva     tmp1, IO_DCB::daux2
        jmp     SIOV
.endproc

.rodata
t_io_mount_disk_image:
        .byte $f8, $00, $00, $00, $fe, $00, $00, $00, $ff, $ff