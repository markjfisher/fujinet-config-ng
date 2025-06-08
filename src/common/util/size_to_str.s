        .export     size_to_str
        .export     size_output

        .import     _memmove
        .import     pushax

        .include    "zp.inc"
        .include    "macros.inc"

; converts 3 bytes from little endian to comma separated string
; input:
;   A/X = pointer to 3 bytes (little endian, range 0-16,777,214)
;   Y = 1 for right justified, 0 for left justified
; output:
;   size_output contains the string (10 chars + null terminator)
;   - left justified: string starts at position 0
;   - right justified: string ends at position 9
;   - includes commas every 3 digits from right (e.g. "16,777,214")
;   - padded with spaces
;   - input data is preserved
; uses:
;   ptr3 - points to input bytes
;   ptr4 - justification flag
;   tmp1-tmp4 - for division/conversion/string length
; cycles:
;   ~2000-6500 depending on number size and comma count
; size:
;   ~220 bytes of code
;   21 bytes of BSS for output buffer (10 chars + null + 10 temp)

.segment "CODE2"

size_to_str:
        axinto  ptr3            ; save input pointer
        sty     ptr4            ; save justification flag (using ptr4 temporarily)

        ; First convert the 3 bytes into a 24-bit number in tmp1-tmp3
        ldy     #0
        lda     (ptr3),y        ; low byte
        sta     tmp1
        iny
        lda     (ptr3),y        ; middle byte
        sta     tmp2
        iny
        lda     (ptr3),y        ; high byte
        sta     tmp3

        ; Initialize output buffer with spaces
        ldx     #9              ; initialize 10 chars (positions 0-9) with spaces
        lda     #' '
:       sta     size_output,x
        dex
        bpl     :-

        ; Special case for zero
        lda     tmp1
        ora     tmp2
        ora     tmp3
        bne     not_zero

        ; Just output "0" at start or end depending on justification
        lda     #'0'
        ldy     ptr4            ; Check justification
        beq     zero_left
        sta     size_output+9   ; Right justified
        jmp     done
zero_left:
        sta     size_output     ; Left justified
        jmp     done

not_zero:
        ; Get digits in reverse order
        ldx     #0              ; digit counter
get_digits:
        ; Divide by 10 (result in tmp1-tmp3, remainder in A)
        lda     #0              ; Clear remainder
        ldy     #24             ; Process all 24 bits

divide_loop:
        ; Shift quotient and remainder left
        asl     tmp1
        rol     tmp2
        rol     tmp3
        rol     a               ; Shift bit into remainder

        ; Try to subtract 10
        cmp     #10
        bcc     no_sub         ; Skip subtraction if remainder < 10

        ; Subtract 10 and set result bit
        sbc     #10
        inc     tmp1            ; Set result bit

no_sub:
        dey
        bne     divide_loop

        ; Convert remainder to ASCII and store
        clc
        adc     #'0'           ; Convert to ASCII
        sta     size_output+10,x  ; Store in temp area
        inx

        ; Continue if quotient not zero
        lda     tmp1
        ora     tmp2
        ora     tmp3
        bne     get_digits

        ; Now X contains number of digits
        ; First copy digits to beginning of buffer
        dex                     ; X now points to last digit
        ldy     #0              ; Y will be destination index
reverse_loop:
        lda     size_output+10,x
        sta     size_output,y
        iny
        dex
        bpl     reverse_loop

        ; Y now contains the number of digits
        sty     tmp4            ; Save digit count

        ; Insert commas every 3 digits from the right
        lda     tmp4            ; Get number of digits
        sec
        sbc     #3              ; Start with first comma position
        sta     tmp1            ; Save insert position

comma_loop:
        lda     tmp1
        beq     justify         ; If at start, handle justification
        bmi     justify         ; Or if negative

        ; Need to insert comma at position tmp1
        ; First shift everything right starting at insert position
        ldx     tmp4            ; Get current length
shift_loop:
        lda     size_output-1,x ; Get character
        sta     size_output,x   ; Move it right
        dex
        cpx     tmp1            ; Until we reach insert position
        bne     shift_loop

        ; Insert the comma
        lda     #','
        sta     size_output,x

        ; Update counters
        inc     tmp4            ; String is one longer
        lda     tmp1            ; Move insert position left 3
        sec
        sbc     #3
        sta     tmp1
        jmp     comma_loop      ; Continue

justify:
        ; Check if we need to right justify
        lda     ptr4
        beq     done            ; If left justified, we're done

        ; Right justify - move string to end
        ; First find out how many positions to move
        lda     #10             ; Total width (0-9, but need to include position 9)
        sec
        sbc     tmp4            ; Subtract current length
        beq     done            ; If zero, no need to move
        sta     tmp1            ; Save number of positions to move

        ; Calculate destination address (size_output + tmp1)
        lda     #<size_output
        clc
        adc     tmp1
        pha                     ; Save low byte for later
        lda     #>size_output
        adc     #0
        tax                     ; High byte in X
        pla                     ; Low byte back in A

        ; Push destination address
        jsr     pushax

        ; Push source address
        setax   #size_output
        jsr     pushax

        ; Set size directly in A/X
        lda     tmp4            ; Length of string
        ldx     #0             ; High byte is 0 as string is < 256 bytes
        ; this affects ptr1-4
        jsr     _memmove

        ; Fill leading positions with spaces
        ldx     tmp1
        dex
        lda     #' '
:       sta     size_output,x
        dex
        bpl     :-

done:   
        ; Add terminator
        lda     #0
        sta     size_output+10  ; Always put null at position 10
        rts

.segment "BANK"
size_output:    .res 21     ; 10 chars + terminator + 10 temp chars for reversing
