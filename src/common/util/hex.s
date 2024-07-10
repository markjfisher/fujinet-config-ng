;         .export     hex
;         .export     hexb

;         .import     popa
;         .import     popax

;         .include    "macros.inc"

; ; It's back! Used to display preference values as hex
; ; Converted to ca65 from https://github.dev/tebe6502/Mad-Assembler/tree/master/examples/hex_reg_var.asm


; ; ------------------------------------------------------
; ; a contains digit to convert
; .proc   lHex
;         pha
;         lsr         a
;         lsr         a
;         lsr         a
;         lsr         a

;         jsr         hex2int
;         tax
;         pla
;         and         #$0f

; hex2int:
;         sed
;         cmp         #$0a
;         adc         #'0'
;         cld
;         rts
; .endproc

; ; ------------------------------------------------------
; ; hex(word value, word output)
; .proc   hex
;         setax   out+1
;         popax   htmpw

;         lda     htmpw
;         jsr     lHex
;         ldy     #$03
;         jsr     put

;         lda     htmpw+1
;         jsr     lHex
;         ldy     #$01
;         jsr     put

;         rts

; put:
;         jsr     out
;         dey
;         txa

;         ; Self Modifying Code
; out:    sta     $ffff, y
;         rts

; .endproc

; ; ------------------------------------------------------
; ; hexb(word value, word output)
; .proc   hexb
;         setax   hex::out+1
;         jsr     popa        ; value to display in a

;         jsr     lHex
;         ldy     #$01
;         jsr     hex::put

;         rts
; .endproc

; .data
; htmpw:  .word 0