        .export     ellipsize
        .export     _ellipsize_params

        .import     _fc_strlen
        .import     _fc_strlcpy
        .import     _fc_strlcpy_params
        .import     pushax

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "ellipsize.inc"
        .include    "fc_strlcpy.inc"

.segment "CODE2"

; void ellipsize()
; Uses _ellipsize_params structure for parameters:
;   dst  - destination buffer
;   src  - source string
;   len  - max length including null terminator
;
; Returns a string with "..." in middle of the string reducing strings above max to that length
; e.g. "123456789" -> "12...89" for max of 7+null = 8 chars
.proc ellipsize
        ; Get source string length
        setax   _ellipsize_params+ellipsize_params::src
        jsr     _fc_strlen
        sta     tmp4    ; store length

        ; Compare with max length
        cmp     _ellipsize_params+ellipsize_params::len
        bcs     :+

        ; String fits, just copy it
        mwa     _ellipsize_params+ellipsize_params::dst, _fc_strlcpy_params+fc_strlcpy_params::dst
        mwa     _ellipsize_params+ellipsize_params::src, _fc_strlcpy_params+fc_strlcpy_params::src
        inc     tmp4    ; add 1 for null
        mva     tmp4, _fc_strlcpy_params+fc_strlcpy_params::size
        jmp     _fc_strlcpy
        ; implicit rts

        ; String too long, need to ellipsize
:       lda     _ellipsize_params+ellipsize_params::len
        sec
        sbc     #$04
        lsr     a
        sta     tmp2    ; rightlen = (max - 4) / 2

        lda     _ellipsize_params+ellipsize_params::len
        and     #$01    ; max % 2
        clc
        adc     tmp2
        sta     tmp3    ; leftlen = rightlen + max % 1

        ; Get source and destination pointers
        mwa     _ellipsize_params+ellipsize_params::src, ptr4
        mwa     _ellipsize_params+ellipsize_params::dst, ptr3

        ; Copy first leftlen chars into dst
        ldy     #$00
:       mva     {(ptr4), y}, {(ptr3), y} ; copy src to dst
        iny
        cpy     tmp3    ; have we done leftlen chars?
        bne     :-

        ; Copy 3 dots
        lda     #'.'
        sta     (ptr3), y
        iny
        sta     (ptr3), y
        iny
        sta     (ptr3), y
        iny

        ; Copy last rightlen chars to dst
        ; y is an index into dst char to write, adjust src
        ; we want to point to: start + total_length - rightlen - y
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

.segment "BANK"
_ellipsize_params: .tag ellipsize_params