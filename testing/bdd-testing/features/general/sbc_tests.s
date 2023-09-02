        .export     sbs_test_1_zp, sbs_test_1_mem, sbs_test_2
        .export     t_b

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; test that sbc/eor #$ff/adc #1 is same as swapping bytes and doing subtraction
; we will perform (t_b - A) in all cases. which is faster and less bytes of memory?

; Use ZP as temp storage. 9 bytes of memory
.proc sbs_test_1_zp
        sta     tmp1
        lda     t_b
        sec
        sbc     tmp1
        rts
.endproc

; Use memory as temp storage. 11 bytes
.proc sbs_test_1_mem
        sta     t_tmp
        lda     t_b
        sec
        sbc     t_tmp
        rts
.endproc

; this version does no temporary storage
; it takes 1 more instruction (clc) but only needed when B <= A. If you could guarantee B > A, then can drop clc
; 10 bytes with clc, 9 without
; would be quicker but more bytes still with "beq" after sbc, as you don't need to do the rest if they are equal.
.proc sbs_test_2
        ; again, assume A is set from somewhere else (test in this case)
        sec
        sbc     t_b
        eor     #$ff
        clc
        adc     #$01
        rts
.endproc


.bss
t_b:    .res 1

t_tmp:  .res 1