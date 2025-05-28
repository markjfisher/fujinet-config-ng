    .export     _main
    .export     t1_end
    .export     t2_end
    .export     t3_end
    .export     t4_end
    .export     t5_end
    .export     t6_end
    .export     t7_end
    .export     t8_end
    .export     t1
    .export     t2
    .export     t3
    .export     t4

    .import     size_to_str

.code

_main:
    ; Test 1: Small number (123) - left justified
    lda     #<t1
    ldx     #>t1
    ldy     #0              ; left justified
    jsr     size_to_str
t1_end:

    ; Test 2: Medium number (12,345) - left justified
    lda     #<t2
    ldx     #>t2
    ldy     #0              ; left justified
    jsr     size_to_str
t2_end:

    ; Test 3: Large number (16,777,214) - left justified
    lda     #<t3
    ldx     #>t3
    ldy     #0              ; left justified
    jsr     size_to_str
t3_end:

    ; Test 4: Zero - left justified
    lda     #<t4
    ldx     #>t4
    ldy     #0              ; left justified
    jsr     size_to_str
t4_end:

    ; Test 5: Small number (123) - right justified
    lda     #<t1
    ldx     #>t1
    ldy     #1              ; right justified
    jsr     size_to_str
t5_end:

    ; Test 6: Medium number (12,345) - right justified
    lda     #<t2
    ldx     #>t2
    ldy     #1              ; right justified
    jsr     size_to_str
t6_end:

    ; Test 7: Large number (16,777,214) - right justified
    lda     #<t3
    ldx     #>t3
    ldy     #1              ; right justified
    jsr     size_to_str
t7_end:

    ; Test 8: Zero - right justified
    lda     #<t4
    ldx     #>t4
    ldy     #1              ; right justified
    jsr     size_to_str
t8_end:

    rts

.data
; Test values in little endian format (3 bytes each)
t1:     .byte $7b, $00, $00        ; 123 (0x0000007B)
t2:     .byte $39, $30, $00        ; 12,345 (0x00003039)
t3:     .byte $FE, $FF, $FF        ; 16,777,214 (0x00FFFFFE)
t4:     .byte $00, $00, $00        ; 0 
