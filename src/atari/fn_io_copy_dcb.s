        .export         _fn_io_copy_dcb
        .include        "atari.inc"
        .include        "zeropage.inc"
        .include        "../inc/macros.inc"

; void _fn_io_copy_dcb(DCB* table)
;
; Sets DCB data from given table address
; DO NOT TRASH tmp1/2 IN THIS ROUTINE - callers use them for storing args.
; We also ONLY use ptr4 from ZP, which should allow our callers ptr1-3 to use
.proc _fn_io_copy_dcb
        getax ptr4

        ; first 2 bytes always $70, $01, so we can do those manually. saves table space, and loops
        mva #$70, DCB
        mva #$01, DCB+1

        ; copy 10 bytes of table into DCB
        ldy #9
:       mva {(ptr4), y}, {DCB+2, y}
        dey
        bpl :-
        rts
.endproc
