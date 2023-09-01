        .export     _fn_strlcpy
        .import     popax, popa
        .include    "fn_macros.inc"
        .include    "zeropage.inc"

; uint8_t fn_strlcpy(char *dst, char *src, uint8_t size)
; This is a cutdown version of strlcpy for use on strings up to 256 characters.
;
; Like strncpy, but:
;  1. guarantees a 0 terminator, even if this means truncating
;  2. copies at most size-1 bytes.
;  3. does not fill rest of size with 0s
;  4. returns length of src

; NOTE: size must be compatible with dst, i.e. it must not exceed its length.

.proc   _fn_strlcpy
        sta     tmp4            ; size (n)
        popax   ptr4            ; src
        popax   ptr3            ; dst

        ldx     tmp4
        beq     no_copy
        dex                     ; always do siz-1 at most chars
        ldy     #$00
:       lda     (ptr4), y
        sta     (ptr3), y
        beq     found0
        iny
        dex
        bne     :-

found0:
no_copy:
        cpx     #$00            ; did we run out of room in dst? i.e. we copied all size bytes?
        bne     :++

        ; yes we ran out of room, need to null terminate
        lda     tmp4
        beq     :+              ; actually no! don't null terminate as size was in fact 0.
        mva     #$00, {(ptr3), y}

:       lda     (ptr4), y       ; next byte of src
        beq     :+
        iny
        bne     :-              ; keep looping until we find the end of src

:       ldx     #$00
        tya                     ; return value is length of src, not including nul
        rts

.endproc
