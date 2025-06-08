    .export     _main
    .export     t1_end
    .export     t2_end
    .export     t3_end
    .export     t4_end

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

    lda     #<t3
    ldx     #>t3    
    jsr     ts_to_datestr
t3_end:

    lda     #<t4
    ldx     #>t4    
    jsr     ts_to_datestr
t4_end:

    rts

; TEST TIMES

.data
;             30+19, F=0|M=10,     DDDDDHHH   HHmmmmmm
t1:      .byte 49,        10,     %11100010, %11000000
;t1s:    .byte "28/10/2019 11:00", 0

t2:      .byte 55, 5, %01001100, %10000001
;t2s:    .byte "09/05/2025 18:01", 0

; Test for YYYY/MM/DD format (format = 2) using same date as t1 but different format
t3:      .byte 49,        (2 << 4) | 10,     %11100010, %11000000
;t3s:    .byte "2019/10/28 11:00", 0

; Test for MM/DD/YYYY format (format = 1) using same date as t2 but different format  
t4:      .byte 55,        (1 << 4) | 5,     %01001100, %10000001
;t4s:    .byte "05/09/2025 18:01", 0
