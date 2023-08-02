; test the hex library

        .import         hex, pushax
        .export         _main, output, t_vw
        .include        "../../../../../src/inc/fn_macros.inc"

.proc _main
        pushax t_vw
        setax #output

        jsr hex
        rts
.endproc

.data
; locations for test to write to
t_vw:   .res 2
output: .res 4
