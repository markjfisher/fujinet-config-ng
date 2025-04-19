        .export     ellipsize

        .import     _fc_strlen
        .import     _fc_strlcpy
        .import     popa
        .import     popax
        .import     pushax

        .include    "zp.inc"
        .include    "macros.inc"

; void ellipsize(uint8_t max, char *dst, char *src)
;
; max includes the zero terminator. i.e. strlen + 1
; returns a string with "..." in middle of the string reducing strings above max to that length, with start and end chars either side
; e.g.
; "123456789" -> "12...89" for max of 7+null = 8 chars
.proc ellipsize
        axinto  ptr4    ; src
        popax   ptr3    ; dst
        popa    tmp1    ; max length

        ; are we short enough to just copy?
        setax   ptr4
        jsr     _fc_strlen
        sta     tmp4    ; store length
        cmp     tmp1
        bcs     :+

        ; yes, use strlcpy
        pushax  ptr3
        pushax  ptr4
        inc     tmp4    ; add 1 for null
        lda     tmp4    ; get length back
        jmp     _fc_strlcpy
        ; implicit rts

        ; no, we need to elipsize
:       lda     tmp1
        sec
        sbc     #$04
        lsr     a
        sta     tmp2    ; rightlen = (max - 4) / 2

        lda     tmp1
        and     #$01    ; max % 2
        clc
        adc     tmp2
        sta     tmp3    ; leftlen = rightlen + max % 1

        ; copy first leftlen chars into dst
        ldy     #$00
:       mva     {(ptr4), y}, {(ptr3), y} ; copy src to dst
        iny
        cpy     tmp3    ; have we done leftlen chars?
        bne     :-

        ; copy 3 dots
        lda     #'.'
        sta     (ptr3), y
        iny
        sta     (ptr3), y
        iny
        sta     (ptr3), y
        iny

        ; copy last rightlen chars to dst
        ; y is an index into dst char to write, adjust src
        ; we want to point to: start + total_length - rightlen - y, which when we index with y will get to (start + total_length - rightlen) which is first char to copy from the end
        adw1    ptr4, tmp4      ; start + total_length
        sbw1    ptr4, tmp2      ;   - rightlen
        tya
        sta     tmp3            ; tmp3 = y
        sbw1    ptr4, tmp3      ;   - y
        ; ptr4 now points to correct location to copy rightlen bytes (tmp2)
        ldx     tmp2
:       mva     {(ptr4), y}, {(ptr3), y}
        iny
        dex
        bne     :-

        mva     #$00, {(ptr3), y}   ; null terminate
        rts

.endproc