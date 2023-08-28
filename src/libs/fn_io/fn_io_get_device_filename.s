        .export         _fn_io_get_device_filename
        .import         _fn_io_copy_dcb, _fn_io_dosiov, popa
        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_data.inc"
 
; void * fn_io_get_device_filename(uint8 device_slot, void *buffer)
.proc _fn_io_get_device_filename
        axinto  ptr1            ; save the buffer pointer
        popa    tmp1            ; save device_slot
        setax   #t_io_get_device_filename
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::daux1
        mwa     ptr1, IO_DCB::dbuflo
        jsr     _fn_io_dosiov

        ; for convenience, return the pointer back to the caller
        ; might be better to have error codes here? Are there any?
        setax   ptr1
        rts
.endproc

.rodata
t_io_get_device_filename:
        .byte $da, $40, $ff, $ff, $0f, $00, $00, $01, $ff, $00

