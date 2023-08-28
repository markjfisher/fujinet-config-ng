        .export         _fn_io_copy_file
        .import         fn_io_copy_dcb, popa, _fn_io_dosiov
        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include         "fn_data.inc"
 
; void fn_io_copy_file(uint8_t src_slot, uint8_t dst_slot, char *copy_spec)
.proc _fn_io_copy_file
        axinto  ptr1    ; copyspec write location
        popa    tmp1    ; dst_slot
        popa    tmp2    ; src_slot

        setax   #t_io_copy_file
        jsr     fn_io_copy_dcb

        ;  fujinet tracks 1-8, we do 0-7, so need to increment both values
        inc     tmp1
        inc     tmp2
        mva     tmp2, IO_DCB::daux1
        mva     tmp1, IO_DCB::daux2
        mwa     ptr1, IO_DCB::dbuflo
        jmp     _fn_io_dosiov
.endproc

.rodata
t_io_copy_file:
        .byte $d8, $80, $ff, $ff, $fe, $00, $00, $01, $ff, $ff
