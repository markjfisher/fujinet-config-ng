        .export     _put_help_status
        .import     popa
        .import     mhlp1, sline1
        .import     ascii_to_code
        .import     _fn_strlen

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; void put_status_help(uint8_t line_num, bool is_status, char *msg)
.proc _put_help_status
        axinto  ptr1            ; save char* msg
        jsr     _fn_strlen
        sta     tmp2            ; string length

        ; read type of call, help or status
        jsr     popa            ; 0 for help, 1 for status - saves 2 procedures doing similar work
        cmp     #$00
        beq     is_help
is_status:
        mwa     #sline1, ptr2   ; get location of first status line into ptr2
        jmp     put_common

is_help:
        mwa     #mhlp1, ptr2    ; get location of first help line into ptr2
        jmp     put_common
.endproc

; common routine to print message
; ASSUMPTION - screen has been cleared before calling this, so no extra spaces to print
.proc put_common
        jsr     popa            ; line number
        beq     over
        tax

        ; jump to correct line
:       adw1    ptr2, #SCR_WIDTH
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
