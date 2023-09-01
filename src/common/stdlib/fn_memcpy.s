        .export     _fn_memcpy, fn_memcpy_fast, _fn_mempcpy, fn_mempcpy_fast

        .import     popax

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; void * fn_memcpy(void* dest, const void* src, uint_8 n)
;
; A cut down version of memcpy, only for up to 255 bytes
; returns dst, destroys tmp4, ptr3, ptr4

.proc _fn_memcpy
        sta     tmp4    ; n
        popax   ptr4    ; src
        popax   ptr3    ; dst

start_copy:
        ldy     tmp4
        beq     no_copy
        dey
:       mva     {(ptr4), y}, {(ptr3), y}
        dey
        bne     :-
        ; do zero'th
        mva     {(ptr4), y}, {(ptr3), y}

no_copy:
        setax   ptr3
        rts
.endproc

; INTERNAL VERSION, these values are directly used
; ptr4 = src
; ptr3 = dst
; tmp4 = n
; reduces run by 50 cycles
.proc fn_memcpy_fast
        jmp     _fn_memcpy::start_copy
.endproc

; void * fn_mempcpy(void* dst, const void* src, uint8_t n)
; returns a pointer to dst + n
.proc _fn_mempcpy
        jsr     _fn_memcpy
add_len:
        adw1    ptr3, tmp4
        setax   ptr3
        rts
.endproc

; INTERNAL VERSION. See above
; returns a pointer to dst + n
; ptr4 = src
; ptr3 = dst
; tmp4 = n
; reduces run by 50 cycles
.proc fn_mempcpy_fast
        jsr     _fn_memcpy::start_copy
        jmp     _fn_mempcpy::add_len
.endproc
