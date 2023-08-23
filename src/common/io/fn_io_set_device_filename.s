        .export         _fn_io_set_device_filename
        .import         _fn_io_copy_dcb, fn_io_buffer, _fn_io_dosiov
        .import         popa

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_data.inc"

; void _fn_io_set_device_filename(uint8 mode, uint8 host_slot, uint8 device_slot)
.proc _fn_io_set_device_filename
        sta     tmp1    ; device_slot
        popa    tmp2    ; host_slot
        popa    tmp3    ; mode

        setax   #t_io_set_device_filename
        jsr     _fn_io_copy_dcb

        ; setup aux2 = host_slot * 16 + mode
        lda     tmp2
        beq     :+
        asl     a
        asl     a
        asl     a
        asl     a
:       clc
        adc     tmp3
        sta     IO_DCB::daux2

        mva     tmp1, IO_DCB::daux1
        jmp     _fn_io_dosiov
.endproc

.rodata
t_io_set_device_filename:
        .byte $e2, $80, <fn_io_buffer, >fn_io_buffer, $0f, $00, $00, $01, $ff, $00
