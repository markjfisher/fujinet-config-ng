        .export     _fc_strlcpy
        .export     _fc_strlcpy_params

        .include    "macros.inc"
        .include    "zp.inc"
        .include    "fc_strlcpy.inc"

; uint8_t fc_strlcpy()
; This is a cutdown version of strlcpy for use on strings up to 256 characters.
; Uses _fc_strlcpy_params structure for parameters:
;   dst  - destination buffer
;   src  - source string
;   size - max size including null terminator
;
; Like strncpy, but:
;  1. guarantees a 0 terminator, even if this means truncating
;  2. copies at most size-1 bytes.
;  3. does not fill rest of size with 0s
;  4. returns length of src in A (X=0)
;
; NOTE: size must be compatible with dst, i.e. it must not exceed its length.
; uses tmp6-tmp9 (tmp6/7 for src, tmp8/9 for dst)

.proc   _fc_strlcpy
        ; Copy src and dst to zp locations
        mwa     _fc_strlcpy_params+fc_strlcpy_params::src, tmp6
        mwa     _fc_strlcpy_params+fc_strlcpy_params::dst, tmp8

        ldx     _fc_strlcpy_params+fc_strlcpy_params::size
        beq     no_copy
        dex                     ; always do size-1 at most chars
        ldy     #$00
:       lda     (tmp6),y
        sta     (tmp8),y
        beq     found0
        iny
        dex
        bne     :-

found0:
no_copy:
        cpx     #$00            ; did we run out of room in dst? i.e. we copied all size bytes?
        bne     :++

        ; yes we ran out of room, need to null terminate
        lda     _fc_strlcpy_params+fc_strlcpy_params::size
        beq     :+              ; actually no! don't null terminate as size was in fact 0.
        lda     #$00
        sta     (tmp8),y

:       lda     (tmp6),y       ; next byte of src
        beq     :+
        iny
        bne     :-              ; keep looping until we find the end of src

:       ldx     #$00
        tya                     ; return value is length of src, not including nul
        rts

.endproc

.segment "BANK"
_fc_strlcpy_params: .tag fc_strlcpy_params
