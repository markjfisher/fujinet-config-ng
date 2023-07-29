; taken from https://github.dev/tebe6502/Mad-Assembler/tree/master/examples/hex_reg_var.asm
; converted to ca65

        .export     hex, hexb
        .import     popax, popa
        .include    "../inc/macros.inc"
        .include    "zeropage.inc"

; ------------------------------------------------------
; a contains digit to convert
.proc   lHex
        pha
        .repeat 4
        lsr a
        .endrepeat

        jsr hex2int
        tax
        pla
        and #$0f

hex2int:
        sed
        cmp #$0a
        adc #'0'
        cld
        rts
.endproc

; ------------------------------------------------------
; hex(word value, word output)
.proc   hex
        getax ptr1
        popax ptr2

        lda ptr2
        jsr lHex
        ldy #$03
        jsr put

        lda ptr2+1
        jsr lHex
        ldy #$01
        jsr put

        rts

put:
        jsr out
        dey
        txa

out:    sta (ptr1), y
        rts

.endproc

; ------------------------------------------------------
; hexb(word value, word output)
.proc   hexb
        getax ptr1
        jsr popa        ; value to display in a

        jsr lHex
        ldy #$01
        jsr hex::put

        rts
.endproc
