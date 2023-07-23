; test the hex library

        .import         hexb, pusha
        .export         _main, output, t_vb
        .include        "../../../../../src/inc/macros.inc"

.proc _main
        _pusha t_vb
        _setax #output

        jsr hexb
        rts
.endproc

.data
; locations for test to write to
t_vb:   .res 1
output: .res 4
