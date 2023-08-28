        .export _fn_io_siov

        .import fn_io_copy_dcb, _fn_io_dosiov

; void _fn_io_siov(dcb_table)
;
; Sets DCB data from passed in dcb_table and calls SIOV
.proc _fn_io_siov
        jsr     fn_io_copy_dcb
        jmp     _fn_io_dosiov
.endproc
