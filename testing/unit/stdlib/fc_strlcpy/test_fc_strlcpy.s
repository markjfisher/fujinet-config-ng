.export _main
.export t1, t2, t3, t4
.export t1_end, t2_end, t3_end, t4_end
.export dst_buf

.import _fc_strlcpy
.import pushax

.include "zp.inc"
.include "macros.inc"

.code
_main:
        jsr     fill_ff         ; Fill dst_buf with $FF pattern

t1:     ; Test count > length, char + 0, no padding
        pushax  #dst_buf        ; dst
        pushax  #src1          ; src
        lda     #3              ; count
        jsr     _fc_strlcpy
t1_end:

        jsr     fill_ff         ; Fill dst_buf with $FF pattern
t2:     ; Test count > length, but only copy count-1
        pushax  #dst_buf        ; dst
        pushax  #src2          ; src
        lda     #3              ; count
        jsr     _fc_strlcpy
t2_end:

        jsr     fill_ff         ; Fill dst_buf with $FF pattern
t3:     ; Test count = length, truncate for nul
        pushax  #dst_buf        ; dst
        pushax  #src3          ; src
        lda     #3              ; count
        jsr     _fc_strlcpy
t3_end:

        jsr     fill_ff         ; Fill dst_buf with $FF pattern
t4:     ; Test count < length, truncate for nul
        pushax  #dst_buf        ; dst
        pushax  #src4          ; src
        lda     #3              ; count
        jsr     _fc_strlcpy
t4_end:
        rts

; Fill dst_buf with $FF pattern
fill_ff:
        lda     #$ff
        ldx     #7
:       sta     dst_buf, x
        dex
        bpl     :-
        rts

.data
src1:   .byte "a", 0                      ; 1 char + null
src2:   .byte "ab", 0                     ; 2 chars + null
src3:   .byte "abc", 0                    ; 3 chars + null
src4:   .byte "abcd", 0                   ; 4 chars + null

.bss
dst_buf:    .res 8     ; Output buffer for all tests 