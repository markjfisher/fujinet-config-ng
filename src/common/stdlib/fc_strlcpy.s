        .export     _fc_strlcpy
        .import     popax
        .include    "macros.inc"
        .include    "zp.inc"

; uint8_t fc_strlcpy(char *dst, char *src, uint8_t size)
; This is a cutdown version of strlcpy for use on strings up to 256 characters.
;
; Like strncpy, but:
;  1. guarantees a 0 terminator, even if this means truncating
;  2. copies at most size-1 bytes.
;  3. does not fill rest of size with 0s
;  4. returns length of src

; NOTE: size must be compatible with dst, i.e. it must not exceed its length.
; uses tmp6-tmp10

.proc   _fc_strlcpy
        sta     tmp6            ; size (n)
        popax   tmp7            ; src
        popax   tmp9            ; dst

        ldx     tmp6
        beq     no_copy
        dex                     ; always do siz-1 at most chars
        ldy     #$00
:       lda     (tmp7), y
        sta     (tmp9), y
        beq     found0
        iny
        dex
        bne     :-

found0:
no_copy:
        cpx     #$00            ; did we run out of room in dst? i.e. we copied all size bytes?
        bne     :++

        ; yes we ran out of room, need to null terminate
        lda     tmp6
         beq     :+              ; actually no! don't null terminate as size was in fact 0.
        mva     #$00, {(tmp9), y}

:       lda     (tmp7), y       ; next byte of src
        beq     :+
        iny
        bne     :-              ; keep looping until we find the end of src

:       ldx     #$00
        tya                     ; return value is length of src, not including nul
        rts

.endproc
