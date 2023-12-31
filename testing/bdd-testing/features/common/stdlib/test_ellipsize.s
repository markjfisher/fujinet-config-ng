        .export         _main, t_src, t_dst, t_max

        .import         _ellipsize, pusha, pushax
        .include        "macros.inc"

.proc _main
        pusha   t_max
        pushax  #t_dst
        setax   #t_src

        jsr _ellipsize
        rts
.endproc

.bss
t_src: .res 64
t_dst: .res 64
t_max: .byte 0