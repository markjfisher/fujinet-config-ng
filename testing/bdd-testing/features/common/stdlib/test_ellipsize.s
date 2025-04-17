        .export         _main, t_src, t_dst, t_max

        .import         ellipsize, pusha, pushax
        .include        "macros.inc"

.proc _main
        pusha   t_max
        pushax  #t_dst
        setax   #t_src

        jsr ellipsize
        rts
.endproc

.bss
t_src: .res 64
t_dst: .res 64
t_max: .byte 0