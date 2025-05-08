        .export _hash_string

        .include "zeropage.inc"

; uint16_t hash_string(const char* str);
;
.proc _hash_string
    ; inputs:
    ; A = low byte of buffer location in memory
    ; X = high byte of buffer location in memory
    ; return:
    ; hash in A/X (A=low byte, X=high byte)

    ; ptr1 is a Zero Page location pointing to the current string
    sta     ptr1
    stx     ptr1+1

    ; Initialize hash to 0
    lda     #0
    sta     tmp1    ; Low byte of hash
    sta     tmp2    ; High byte of hash

    ; Use Y as index into string
    ldy     #0

loop:
    ; Load next character
    lda     (ptr1),y
    beq     done        ; If zero, we're done
    tax                 ; Save original char value

    ; XOR with low byte directly
    eor     tmp1
    sta     tmp1

    ; XOR with high byte but rotate char right by 3 first
    txa                 ; Get char back
    ; Rotate right 3 = rotate left 5
    lsr     a
    lsr     a
    lsr     a           ; Shifted right 3
    sta     ptr2        ; Store partial result
    txa                 ; Get char back
    asl     a
    asl     a
    asl     a
    asl     a
    asl     a           ; Shifted left 5
    ora     ptr2        ; Combine parts
    eor     tmp2        ; XOR with high byte
    sta     tmp2

    ; Mix between bytes
    ; First tmp1 ^= tmp2
    lda     tmp2
    eor     tmp1
    sta     tmp1

    ; Then tmp2 ^= (tmp1 rotated left 3)
    tax                 ; Save tmp1 value
    lsr     a
    lsr     a
    lsr     a
    lsr     a
    lsr     a           ; Shifted right 5
    sta     ptr2        ; Store partial result
    txa                 ; Get tmp1 back
    asl     a
    asl     a
    asl     a           ; Shifted left 3
    ora     ptr2        ; Combine parts
    eor     tmp2
    sta     tmp2

    ; 16-bit rotation left by 2
    ; Do this twice

    ldx     #$01
    ; Perform rotation
do_rot:
    asl     tmp1        ; Shift low byte left, bit 7 -> carry
    rol     tmp2        ; Shift high byte left with carry
    bcc     :+          ; If no carry, skip
    lda     tmp1
    ora     #1          ; Set bit 0 if carry was set
    sta     tmp1
:
    dex
    bpl     do_rot

    ; Add 31 to low byte with carry handling
    lda     tmp1
    clc
    adc     #31
    sta     tmp1
    bcc     no_carry    ; If no carry needed, skip special handling

    ; We had wraparound, so carry to high byte
    ; But first rotate high byte right by 1
    lda     tmp2
    lsr     a           ; Shift right, bit 0 -> carry
    bcc     :+          ; If no carry, skip
    ora     #$80        ; Set bit 7 if carry was set
:   sta     tmp2
    inc     tmp2        ; Add the carry

no_carry:
    ; Next character
    iny
    bne     loop

done:
    ; Return hash in A/X (A=low byte, X=high byte)
    ldx     tmp2
    lda     tmp1
    rts
.endproc
