    .export     _main
    .export     t_t1, t_t2, t_t3, t_t4, t_t5, t_t6, t_t7, t_t8, t_t9
    .export     t_w1, t_w2, t_w3
    .export     test1_end, test2_end, test3_end, test4_end
    .export     test5_end, test6_end, test7_end, test8_end, test9_end

    .include    "macros.inc"

; this will setup test data and run all test cases
_main:
    ; Test 1: word - immediate word
    mwa     t_w1, t_t1
    sbw     t_t1, #$1111        ; #$4321 - #$1111 = #$3210
test1_end:

    ; Test 2: word - word
    mwa     t_w1, t_t2
    sbw     t_t2, t_w2          ; #$4321 - #$0fff = #$3322
test2_end:

    ; Test 3: word - immediate word with destination
    sbw     t_w1, #$2222, t_t3  ; #$4321 - #$2222 = #$20ff
test3_end:

    ; Test 4: word - word with destination
    sbw     t_w1, t_w2, t_t4    ; #$4321 - #$0fff = #$3322
test4_end:

    ; Test 5: word - immediate byte (no borrow)
    mwa     t_w1, t_t5
    sbw     t_t5, #$01          ; #$4321 - #$01 = #$4320
test5_end:

    ; Test 6: word - immediate byte (with borrow)
    mwa     t_w1, t_t6
    sbw     t_t6, #$cd          ; #$4321 - #$cd = #$4254
test6_end:

    ; Test 7: word - immediate byte with destination (no borrow)
    sbw     t_w1, #$01, t_t7    ; #$4321 - #$01 = #$4320
test7_end:

    ; Test 8: word - immediate byte with destination (with borrow)
    sbw     t_w1, #$cd, t_t8    ; #$4321 - #$cd = #$4254
test8_end:

    ; Test 9: immediate word - immediate word with destination (new test)
    sbw     #$4321, #$1111, t_t9 ; #$4321 - #$1111 = #$3210
test9_end:

    rts

; Test data - input values
.data
t_w1:   .word $4321     ; Base test value
t_w2:   .word $0fff     ; Test value
t_w3:   .word $1111     ; Simple test value

; Target locations for test results
.bss
t_t1:   .res 2          ; Test 1 result
t_t2:   .res 2          ; Test 2 result
t_t3:   .res 2          ; Test 3 result
t_t4:   .res 2          ; Test 4 result
t_t5:   .res 2          ; Test 5 result
t_t6:   .res 2          ; Test 6 result
t_t7:   .res 2          ; Test 7 result
t_t8:   .res 2          ; Test 8 result
t_t9:   .res 2          ; Test 9 result 