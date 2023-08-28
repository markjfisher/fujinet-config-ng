        .export         _fn_io_get_device_filename
        .import         fn_io_copy_dcb, _fn_io_dosiov, popa
        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_data.inc"
 
; void fn_io_get_device_filename(uint8_t device_slot, char *buffer)
.proc _fn_io_get_device_filename
        axinto  ptr1            ; save the buffer pointer
        popa    tmp1            ; save device_slot
        setax   #t_io_get_device_filename
        jsr     fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        mwa     ptr1, IO_DCB::dbuflo
        jmp     _fn_io_dosiov

.endproc

.rodata
t_io_get_device_filename:
        .byte $da, $40, $ff, $ff, $0f, $00, $00, $01, $ff, $00

