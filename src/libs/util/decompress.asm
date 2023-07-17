; decompression routine
; converted from original at http://www.retrosoftware.co.uk/forum/viewtopic.php?f=73&t=999

; this is for allowing compressed images to be stored in app, and decompressed into screen memory
; It's only 77 or so bytes, so with the reduced images sizes, saves a few hundred bytes of memory overall

        .extrn t1, t2 .byte
        .public decompress
        .reloc
decompress  .proc ( .word t1, t2 ) .var
        ; t1 = src, t2 = dst
        ldx #$00
for
        lda (t1, x)                     ; next control byte
        beq done                        ; 0 signals end of decompression
        bpl copy_raw                    ; msb=0 means just copy this many bytes from source
        add #$82                        ; flip msb, then add 2, we wont request 0 or 1 as that wouldn't save anything
        sta decompress_tmp              ; count of bytes to copy (>= 2)
        ldy #$01                        ; byte after control is offset
        lda (t1), y                     ; offset from current t1 - 256
        tay

        lda #$02                        ; advance t1 past the control byte and offset
        add:sta t1
        scc:inc t1 + 1

copy_previous                           ; copy tmp bytes from t2 - 256 + offset
        dec t2 + 1                      ; -256
        lda (t2), y                     ; +y
        inc t2 + 1                      ; +256
        sta (t2, x)                     ; +0
        inc t2                          ; INC t2 (used for both t1 of copy (-256) and t2)
        sne:inc t2 + 1

        dec decompress_tmp              ; count down bytes to copy
        bne copy_previous
        beq for                         ; after copying, go back for next control byte

copy_raw
        tay                             ; bytes to copy from t1
copy
        inc t1                          ; INC t1 (1st time past control byte)
        sne:inc t1 + 1
        dey
        bmi for
        mva (t1, x) (t2, x)             ; copy bytes
        inc t2                          ; INC t2
        sne:inc t2 + 1
        bne copy                        ; rest of bytes ; #1 replace with jmp if wrapping back to &0000 is required

done
        rts

decompress_tmp :2 .byte

        .endp
