; test adw macro
    .include    "../../../../src/inc/fn_macros.inc"

    .export test_adw
    .export t_t1, t_t2, t_t3, t_t4

.code

test_adw:
    ; --------------------------------
    ; 2 ARGS - store into first arg

    ; immediate value
    mwa t_w1, t_t1
    adw t_t1, #$1111        ; #$1234 + #$1111 = #$2345

    ; address values
    mwa t_w1, t_t2
    adw t_t2, t_w2          ; #$1234 + #$a013 = #$b247

    ; --------------------------------
    ; 3 ARGS - store into last arg

    ; immediate value
    adw t_w1, #$2222, t_t3  ; #$1234 + #$2222 = #$3456

    ; address values
    adw t_w2, t_w3, t_t4    ; #$a013 + #$1111 = #$b124

    rts

; input data from memory locations
t_w1:   .word $1234
t_w2:   .word $a013
t_w3:   .word $1111

; target address for writing to that will be read in test
t_t1:   .word $0000
t_t2:   .word $0000
t_t3:   .word $0000
t_t4:   .word $0000
