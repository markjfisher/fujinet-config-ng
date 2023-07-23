; taken from https://github.dev/tebe6502/Mad-Assembler/tree/master/examples/hex_reg_var.asm
; converted to ca65

        .export     hex, hexb
        .importzp   tmp1, ptr1, ptr2
        .import     popax, popa

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
        ; A/X contain output address
        sta out+1
        stx out+2

        ; stack A/X contains value to display
        jsr popax
        sta htmpw
        stx htmpw+1

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

out:    sta $ffff, y
        rts

.endproc

; ------------------------------------------------------
; hexb(word value, word output)
.proc   hexb
        ; A/X contain output address
        sta hex::out+1
        stx hex::out+2

        ; stack A contains value to display
        jsr popa

        jsr lHex
        ldy #$01
        jsr hex::put

        rts
.endproc

.data
htmpw:  .word 0