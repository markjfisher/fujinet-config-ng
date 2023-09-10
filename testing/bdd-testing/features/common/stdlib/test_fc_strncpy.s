; test the stdlib library

        .import         _fc_strncpy, pusha, pushax
        .export         _main, t_src, t_dst, t_c
        .include        "fn_macros.inc"

.proc _main
        ; args:  #dst #src count
        pushax  #t_dst
        pushax  #t_src
        lda     t_c

        jsr     _fc_strncpy
        rts
.endproc

.bss
t_src: .res 64
t_dst: .res 64
t_c:   .byte 0