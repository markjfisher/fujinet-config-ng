        .export     ascii_to_code

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