; decompression routine
; converted from original at http://www.retrosoftware.co.uk/forum/viewtopic.php?f=73&t=999

; this is for allowing compressed images to be stored in app, and decompressed into screen memory
; It's only 77 or so bytes, so with the reduced images sizes, saves a few hundred bytes of memory overall

        .extrn d_src, d_dst .byte

        .public decompress
        .reloc

decompress  .proc
        ldx #$00
for
        lda (d_src, x)                  ; next control byte
        beq done                        ; 0 signals end of decompression
        bpl copy_raw                    ; msb=0 means just copy this many bytes from source
        add #$82                        ; flip msb, then add 2, we wont request 0 or 1 as that wouldn't save anything
        sta decompress_tmp              ; count of bytes to copy (>= 2)
        ldy #$01                        ; byte after control is offset
        lda (d_src), y                  ; offset from current d_src - 256
        tay

        lda #$02                        ; advance d_src past the control byte and offset
        add:sta d_src
        scc:inc d_src + 1

copy_previous                           ; copy tmp bytes from d_dst - 256 + offset
        dec d_dst + 1                   ; -256
        lda (d_dst), y                  ; +y
        inc d_dst + 1                   ; +256
        sta (d_dst, x)                  ; +0
        inc d_dst                       ; INC d_dst (used for both d_src of copy (-256) and d_dst)
        sne:inc d_dst + 1

        dec decompress_tmp              ; count down bytes to copy
        bne copy_previous
        beq for                         ; after copying, go back for next control byte

copy_raw
        tay                             ; bytes to copy from d_src
copy
        inc d_src                       ; INC d_src (1st time past control byte)
        sne:inc d_src + 1
        dey
        bmi for
        mva (d_src, x) (d_dst, x)       ; copy bytes
        inc d_dst                       ; INC d_dst
        sne:inc d_dst + 1
        bne copy                        ; rest of bytes ; #1 replace with jmp if wrapping back to &0000 is required

done
        rts

decompress_tmp
        dta a($0000)

        .endp

        blk update public
        blk update address
        blk update external