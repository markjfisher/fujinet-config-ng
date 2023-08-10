        .export         _fn_io_copy_file
        .import         _fn_io_copy_dcb, fn_io_buffer, popa
        .include        "atari.inc"
        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include         "fn_structs.inc"
 
; void _fn_io_copy_file(uint8 src_slot, uint8 dst_slot)
.proc _fn_io_copy_file
        sta     tmp1    ; dst_slot
        popa    tmp2    ; src_slot

        setax   #t_io_copy_file
        jsr     _fn_io_copy_dcb

        ;  fujinet tracks 1-8, we do 0-7, so need to increment both values
        inc     tmp1
        inc     tmp2
        mva     tmp2, IO_DCB::daux1
        mva     tmp1, IO_DCB::daux2
        jmp     SIOV
.endproc

.rodata

t_io_copy_file:
        .byte $d8, $80, <fn_io_buffer, >fn_io_buffer, $fe, $00, $00, $01, $ff, $ff
