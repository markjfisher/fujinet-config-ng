        .export     ascii_to_code
        .export     _code_to_ascii

; common routine to convert ascii code in A into internal code for screen
; from cc65/libsrc/atari/cputc.s
.proc   ascii_to_code
        asl     a               ; shift out the inverse bit
        adc     #$c0            ; grab the inverse bit; convert ATASCII to screen code
        bpl     codeok          ; screen code ok?
        eor     #$40            ; needs correction
codeok: lsr     a               ; undo the shift
        bcc     :+
        eor     #$80            ; restore the inverse bit
:       rts
.endproc

;;; char code_to_ascii(char c)
;;;
;;; Convert a screen code to an ASCII character.
;;;
;;; Input: A - Screen code
;;; Output: A - ASCII character

; I wrote this with pencil and paper to check the bits.
; logically: A between 0-63 add 32, between 64-95 sub 64, 96-127 do nothing.
; Same for 127+ bit, just preserve inverse bit.

.proc   _code_to_ascii
        asl     a                ; capture inverse bit in c
        adc     #$00             ; move inverse bit into bit 0 while we test top bits

        clc
        bpl     under_64

        ; for range 64-95, subtract 64.
        ; for range 96-127, do nothing.
        adc     #$c0             ; manipluate the top bits to check what range we are in
        eor     #$40             ; wrt original A: range 64-95 it flips bit 6 to 0, 96-127 it flips bit 6 to 1

reset_inverse_bit:
        lsr     a
        bcc     :+
        eor     #$80             ; restore the inverse bit
:       rts

under_64:
        ; add 32 to the original A, the value will be shifted so we add 64 pre-shift
        adc     #$40
        bcc     reset_inverse_bit

.endproc
