.export _main
.export t1, t2, t3
.export t1_end, t2_end, t3_end
.export dst_buf

.import ellipsize
.import pusha
.import pushax

.include "zp.inc"
.include "macros.inc"

.code
_main:

t1:     ; Test string under max size (should copy as-is)
        lda     #8              ; max length including null
        jsr     pusha
        setax   #dst_buf
        jsr     pushax
        setax   #src1
        jsr     ellipsize
t1_end:

t2:     ; Test string exactly at max size (should copy as-is)
        lda     #6              ; "12345\0"
        jsr     pusha
        setax   #dst_buf
        jsr     pushax
        setax   #src2
        jsr     ellipsize
t2_end:

t3:     ; Test string above max size (should ellipsize)
        lda     #8              ; "12...89\0"
        jsr     pusha
        setax   #dst_buf
        jsr     pushax
        setax   #src3
        jsr     ellipsize
t3_end:
        rts

.data
src1:   .byte "1234", 0                    ; Short string (4+1 bytes)
src2:   .byte "12345", 0                  ; Exact length match (5+1 bytes)
src3:   .byte "123456789", 0              ; Too long, needs ellipsis (9+1 bytes)

.bss
dst_buf:    .res 32     ; Output buffer for all tests 