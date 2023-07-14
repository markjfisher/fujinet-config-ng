; taken from https://github.dev/tebe6502/Mad-Assembler/tree/master/examples/hex_reg_var.asm
; as an example of using .reg and .var in .proc

        .reloc
        .public hex, hexb

; convert byte in a to digit
lHex    .proc ( .byte a ) .reg

        pha         ; store a
    :4  lsr @       ; @ is the accumulator, a = a * 16

        jsr hex2int

        tax     ; store a*16 in x for later

        pla         ; restore a
        and #$0f

hex2int sed
        cmp #$0a        ; set C if a >= 10!, which in decimal mode adds one to next digit along
        adc #"0"
        cld
        rts
        .endp

; take a BYTE value to show and an address to write to.
; note we hijack hex.out and hex.put as they become global
hexb    .proc ( .byte p1 .word hex.out+1 ) .var
        .var p1 .byte

        lHex p1
        ldy #1
        jsr hex.put
        rts
        .endp

; take a WORD value to show, and an address to write to.
; note the +1 which will write the address after the 'sta' part!
hex     .proc ( .word p1, out+1 ) .var
        .var p1 .word

        lHex p1     ; takes the first byte of p1 and passes to lHex
        ldy #$03
        jsr put
        
        lHex p1+1   ; second byte of p1
        ldy #$01
        jsr put

        rts

put     jsr out
        dey
        txa         ; a*16 we stored earlier, drop into out...

; location is overwritten with proc param
; SMC - Self Modifying Code
out     sta $ffff, y
        rts

        .endp
