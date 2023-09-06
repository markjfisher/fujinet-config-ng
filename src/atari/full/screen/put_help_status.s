        .export     _put_help
        .export     _put_status
        .import     popa
        .import     mhlp1, sline1
        .import     ascii_to_code
        .import     _fn_strlen

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; void put_status(uint8_t line_num, char *msg)
.proc _put_status
        axinto  ptr1            ; save char* msg
        mwa     #sline1, ptr2   ; get location of first status line into ptr2
        ; fall into put_common

; ASSUMPTION - screen has been cleared before calling this, so no extra spaces to print
put_common:
        setax   ptr1
        jsr     _fn_strlen
        sta     tmp2            ; string length

        jsr     popa            ; line number
        tax                     ; this also sets the Z flag, as popa doesn't set it correctly
        beq     over

        ; jump to correct line
:       adw1    ptr2, #SCR_BYTES_W
        dex
        bne     :-

over:
        ; calculate shift for centring the string in SCR_WIDTH wide screen
        lda     #SCR_WIDTH
        sec
        sbc     tmp2
        lsr     a               ; (SCR_WIDTH-len)/2 = padding
        sta     tmp3

        ; increase ptr2 by padding
        adw1    ptr2, tmp3

        ldy     #$00
:       lda     (ptr1), y
        jsr     ascii_to_code
        sta     (ptr2), y
        iny
        cpy     tmp2
        bne     :-

        rts
.endproc

; void put_help(uint8_t line_num, char *msg)
.proc _put_help
        axinto  ptr1            ; save char* msg
        mwa     #mhlp1, ptr2    ; get location of first help line into ptr2
        jmp     _put_status::put_common
.endproc

