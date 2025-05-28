    .export     _main
    .export     t_t1, t_t2, t_t3, t_t4, t_t5, t_t6, t_t7, t_t8, t_t9
    .export     t_w1, t_w2, t_w3
    .export     test1_end, test2_end, test3_end, test4_end
    .export     test5_end, test6_end, test7_end, test8_end, test9_end

    .include    "macros.inc"

; this will setup test data and run all test cases
_main:
    ; Test 1: word + immediate word
    mwa     t_w1, t_t1
    adw     t_t1, #$1111        ; #$1234 + #$1111 = #$2345
test1_end:

    ; Test 2: word + word
    mwa     t_w1, t_t2
    adw     t_t2, t_w2          ; #$1234 + #$a013 = #$b247
test2_end:

    ; Test 3: word + immediate word with destination
    adw     t_w1, #$2222, t_t3  ; #$1234 + #$2222 = #$3456
test3_end:

    ; Test 4: word + word with destination
    adw     t_w2, t_w3, t_t4    ; #$a013 + #$1111 = #$b124
test4_end:

    ; Test 5: word + immediate byte (no carry)
    mwa     t_w1, t_t5
    adw     t_t5, #$01          ; #$1234 + #$01 = #$1235
test5_end:

    ; Test 6: word + immediate byte (with carry)
    mwa     t_w1, t_t6
    adw     t_t6, #$cd          ; #$1234 + #$cd = #$1301
test6_end:

    ; Test 7: word + immediate byte with destination (no carry)
    adw     t_w1, #$01, t_t7    ; #$1234 + #$01 = #$1235
test7_end:

    ; Test 8: word + immediate byte with destination (with carry)
    adw     t_w1, #$cd, t_t8    ; #$1234 + #$cd = #$1301
test8_end:

    ; Test 9: immediate word + immediate word with destination (new test)
    adw     #$1234, #$5678, t_t9 ; #$1234 + #$5678 = #$68ac
test9_end:

    rts

; Test data - input values
.data
t_w1:   .word $1234     ; Base test value
t_w2:   .word $a013     ; Large test value
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