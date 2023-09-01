        .export         test_fn_memcpy, test_fn_memcpy_fast, t_src, t_dst, t_max

        .import         _fn_memcpy, pusha, pushax, fn_memcpy_fast

        .include        "zeropage.inc"
        .include        "fn_macros.inc"

test_fn_memcpy:
        pushax  #t_dst
        pushax  #t_src
        lda     t_max

        jmp     _fn_memcpy

test_fn_memcpy_fast:
        mwa     #t_dst, ptr3
        mwa     #t_src, ptr4
        mva     t_max, tmp4

        jmp     fn_memcpy_fast

.bss
t_src: .res 16
t_dst: .res 16
t_max: .byte 0