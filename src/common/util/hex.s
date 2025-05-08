        .export     hex_out
        .export     hexb

; It's back! Used to display preference values as hex
; Converted to ca65 from https://github.dev/tebe6502/Mad-Assembler/tree/master/examples/hex_reg_var.asm


; ------------------------------------------------------
; a contains digit to convert
.proc   lHex
        pha
        lsr         a
        lsr         a
        lsr         a
        lsr         a

        jsr         hex2int
        tax
        pla
        and         #$0f

hex2int:
        sed
        cmp         #$0a
        adc         #'0'
        cld
        rts
.endproc

; ------------------------------------------------------
; output a hex byte.
;
; caller is expected to modify hex_out+1/+2 to location to write to
; input: A = byte to convert to character
;
hexb:
        jsr     lHex
        ldy     #$01

hex_put:
        jsr     hex_out
        dey
        txa
        ; fall through for 2nd digit

hex_out:
        sta     $ffff, y
        rts
