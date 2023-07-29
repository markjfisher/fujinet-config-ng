        .export         io_copy_dcb
        .include        "atari.inc"
        .include        "zeropage.inc"
        .include        "../inc/macros.inc"

; void io_copy_dcb(DCB* table)
;
; Sets DCB data from given table address
; DO NOT TRASH tmp1 IN THIS ROUTINE - callers use it
.proc io_copy_dcb
        getax ptr1

        ; first 2 bytes always $70, $01, so we can do those manually. saves table space, and loops
        mva #$70, DCB
        mva #$01, DCB+1

        ; copy 10 bytes of table into DCB
        ldy #9
:       mva {(ptr1), y}, {DCB+2, y}
        dey
        bpl :-
        rts
.endproc
