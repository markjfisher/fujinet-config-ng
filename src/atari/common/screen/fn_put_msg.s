        .export     _fn_put_help, _fn_put_status
        .import     popa
        .import     mhlp1, sline1
        .import     ascii_to_code
        .import     _fn_strlen

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void fn_put_help(uint8_t line_num, char *msg)
.proc _fn_put_help
        axinto  ptr1            ; save char* msg
        popa    tmp1            ; line number
        mwa     #mhlp1, ptr2    ; get location of first help line into ptr2
        jmp     fn_put_msg
.endproc

; void fn_put_status(uint8_t line_num, char *msg)
.proc _fn_put_status
        axinto  ptr1            ; save char* msg
        popa    tmp1            ; line number
        mwa     #sline1, ptr2    ; get location of first status line into ptr2
        jmp     fn_put_msg
.endproc

; common routine to print message
; ASSUMPTION - screen has been cleared before calling this, so no extra spaces to print
.proc fn_put_msg
        setax   ptr1
        jsr     _fn_strlen
        sta     tmp2            ; string length

        ldx     tmp1
        beq     over

        ; jump to correct line
:       adw     ptr2, #40
        dex
        bne     :-

over:
        ; calculate shift for centring the string in 40 wide screen
        lda     #40
        sec
        sbc     tmp2
        lsr     a               ; (40-len)/2 = padding
        sta     tmp3

        ; increase ptr2 by padding
        adw1    ptr2, tmp3

        ldy     #$00
; now print the string - the ascii conversion isn't too intense, we're only doing a few bytes on screen starts, which relaxes the "40 char" rule
:       lda     (ptr1), y
        jsr     ascii_to_code
        sta     (ptr2), y
        iny
        cpy     tmp2
        bne     :-

        rts
.endproc
