        .export     _put_help
        .export     _put_status
        .import     popa
        .import     mhlp1, sline1
        .import     ascii_to_code
        .import     _fc_strlen

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

; void put_status(uint8_t line_num, char *msg)
.proc _put_status
        axinto  tmp9            ; save char* msg
        mwa     #sline1, tmp7   ; get location of first status line into tmp7
        ; fall into put_common

; ASSUMPTION - screen has been cleared before calling this, so no extra spaces to print
put_common:
        setax   tmp9
        jsr     _fc_strlen      ; doesn't trash tmp9 in this instance
        sta     tmp6            ; string length

        jsr     popa            ; line number
        tax                     ; this also sets the Z flag, as popa doesn't set it correctly
        beq     over

        ; jump to correct line
:       adw1    tmp7, #SCR_BYTES_W
        dex
        bne     :-

over:
        ; calculate shift for centring the string in SCR_WIDTH wide screen
        lda     #SCR_WIDTH
        sec
        sbc     tmp6
        lsr     a               ; (SCR_WIDTH-len)/2 = padding

        ; increase tmp7 by padding
        adw1    tmp7, a

        ldy     #$00
:       lda     (tmp9), y
        jsr     ascii_to_code
        sta     (tmp7), y
        iny
        cpy     tmp6
        bne     :-

        rts
.endproc

; void put_help(uint8_t line_num, char *msg)
; currently only 1 help line, so line_num is always 0
.proc _put_help
        axinto  tmp9            ; save char* msg
        mwa     #mhlp1, tmp7    ; get location of first help line into tmp7
        jmp     _put_status::put_common
.endproc

