; taken from https://github.dev/tebe6502/Mad-Assembler/tree/master/examples/hex_reg_var.asm
; converted to ca65

        .export     hex, hexb
        .import     popax, popa
        .include    "../inc/macros.inc"

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
        getax out+1
        popax htmpw

        lda htmpw
        jsr lHex
        ldy #$03
        jsr put

        lda htmpw+1
        jsr lHex
        ldy #$01
        jsr put

        rts

put:
        jsr out
        dey
        txa

        ; Self Modifying Code
out:    sta $ffff, y
        rts

.endproc

; ------------------------------------------------------
; hexb(word value, word output)
.proc   hexb
        getax hex::out+1
        jsr popa        ; value to display in a

        jsr lHex
        ldy #$01
        jsr hex::put

        rts
.endproc

.data
htmpw:  .word 0