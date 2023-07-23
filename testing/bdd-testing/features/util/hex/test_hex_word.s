; test the hex library

        .import         hex, pushax
        .export         _main, output, t_vw
        .include        "../../../../../src/inc/macros.inc"

.proc _main
        _pushax t_vw
        _setax #output

        jsr hex
        rts
.endproc

.data
; locations for test to write to
t_vw:   .res 2
output: .res 4
