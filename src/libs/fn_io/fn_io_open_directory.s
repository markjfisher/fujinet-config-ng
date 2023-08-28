        .export     _fn_io_open_directory

        .import     fn_io_copy_dcb, _fn_io_dosiov
        .import     popa, return0

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; int _fn_io_open_directory(uint8_t host_slot, void *buffer)
;
.proc _fn_io_open_directory
        axinto  ptr1            ; buffer save location
        popa    tmp1            ; save the host_slot

        setax   #t_io_open_directory
        jsr     fn_io_copy_dcb

        ; set the host_slot into DAUX1, and buffer in dbuflow
        mva     tmp1, IO_DCB::daux1
        mwa     ptr1, IO_DCB::dbuflo

        jsr     _fn_io_dosiov
        jmp     return0

.endproc

.rodata
t_io_open_directory:
        .byte $f7, $80, $ff, $ff, $0f, $00, $00, $01, $ff, $00
