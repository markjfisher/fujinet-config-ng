.export _main
.export t1, t2, t3
.export t1_end, t2_end, t3_end
.export dst_buf

.import ellipsize
.import _ellipsize_params

.include "zp.inc"
.include "macros.inc"
.include "ellipsize.inc"

.code
_main:

t1:     ; Test string under max size (should copy as-is)
        mwa     #dst_buf, _ellipsize_params+ellipsize_params::dst
        mwa     #src1, _ellipsize_params+ellipsize_params::src
        mva     #8, _ellipsize_params+ellipsize_params::len    ; max length including null
        jsr     ellipsize
t1_end:

t2:     ; Test string exactly at max size (should copy as-is)
        mwa     #dst_buf, _ellipsize_params+ellipsize_params::dst
        mwa     #src2, _ellipsize_params+ellipsize_params::src
        mva     #6, _ellipsize_params+ellipsize_params::len    ; "12345\0"
        jsr     ellipsize
t2_end:

t3:     ; Test string above max size (should ellipsize)
        mwa     #dst_buf, _ellipsize_params+ellipsize_params::dst
        mwa     #src3, _ellipsize_params+ellipsize_params::src
        mva     #8, _ellipsize_params+ellipsize_params::len    ; "12...89\0"
        jsr     ellipsize
t3_end:
        rts

.data
src1:   .byte "1234", 0                    ; Short string (4+1 bytes)
src2:   .byte "12345", 0                  ; Exact length match (5+1 bytes)
src3:   .byte "123456789", 0              ; Too long, needs ellipsis (9+1 bytes)

.bss
dst_buf:    .res 32     ; Output buffer for all tests 