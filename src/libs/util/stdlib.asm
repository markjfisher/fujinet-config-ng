; a place for common standard functions from string, stdlib etc.

        .extrn t1, t2 .byte
        .public strcpy, strappend
        .reloc

; ########################################################################
; strcpy
; copy a string up to 256 bytes, or null terminator
; This can overrun if you have no null terminator, and your buffer is only 256
; chars. CALLER BEWARE.
;
; Example:
;    strcpy #src #dst
; src :32 .byte
; dst :32 .byte

; AWESOME! We can copy word param values directly into zp like this,
; which avoids additional memory allocations.

.proc strcpy ( .word t1, t2 ) .var

start
        ldy #0
again   mva (t1),y (t2),y
        beq done
        iny
        bne again

done
        rts
        .endp

; ########################################################################
; strappend
; append string in src to dst. starting at first nul char in src.
; this will first find the char to insert at.
; returns a = 0 if no error, 1 otherwise 
;
; Example:
;    strappend #src #dst
; src :32  .byte
; dst :256 .byte

.proc strappend ( .word t1, t2 ) .var
        ; find first nul char in dst (t2)
        ldy #$00
@       lda (t2), y
        beq found
        iny
        ; rolled around to 0 and didn't find anything
        beq error
        bne @-

found   tya
        clc
        adc t2
        sta t2
        scc:inc t2+1

        ; use strcpy
        jsr strcpy.start
        lda #$00
        rts

error   lda #$01
        rts
        .endp
