; test the stdlib library

        .import         strncpy, pusha, pushax
        .export         _main, t_src, t_dst, t_c
        .include        "../../../../src/inc/macros.inc"

.proc _main
        ; args:  #dst #src count
        _pushax  #t_dst
        _pushax  #t_src
        lda     t_c

        jsr strncpy
        rts
.endproc

.bss
t_src: .res 64
t_dst: .res 64
t_c:   .byte 0