    .export     _main
    .export     t1_end
    .export     t2_end

    .import     ts_to_datestr
    .import     itoa_args

.code
; this will setup any appropriate data required for the function and then run it.
; for this simple test, there's no parameters or anything to setup, so just call it.
_main:

    lda     #<t1
    ldx     #>t1    
    jsr     ts_to_datestr
t1_end:

    lda     #<t2
    ldx     #>t2    
    jsr     ts_to_datestr
t2_end:

    rts

; TEST TIMES

.data
;             30+19, F=0|M=10,     DDDDDHHH   HHmmmmmm
t1:      .byte 49,        10,     %11100010, %11000000
;t1s:    .byte "28/10/2019 11:00", 0

t2:      .byte 55, 5, %01001100, %10000001
;t2s:    .byte "09/05/2025 18:01", 0
