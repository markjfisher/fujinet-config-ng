        .export         _fn_io_copy_dcb

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_data.inc"
        .include        "fn_io.inc"

; void fn_io_copy_dcb(DCB* table)
;
; Sets DCB data from given table address
; DO NOT TRASH tmp1/2 IN THIS ROUTINE - callers use them for storing args.
; We also ONLY use ptr4 from ZP, which should allow our callers ptr1-3 to use
.proc _fn_io_copy_dcb
        axinto  ptr4

        ; first 2 bytes always $70, $01, so we can do those manually. saves table space, and loops
        mva     #$70, IO_DCB::ddevic
        mva     #$01, IO_DCB::dunit

        ; copy 10 bytes of table into DCB
        ldy     #9
:       mva     {(ptr4), y}, {IO_DCB::dcomnd, y}
        dey
        bpl     :-

        rts
.endproc
