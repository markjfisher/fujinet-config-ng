        .reloc
        .public copy_to_screen
        .extrn mod_d, m_l1 .word
        .extrn t1, t2 .byte

copy_to_screen  .proc
        ; copy 36x16 bytes from mod_d to m_l1+2
        mwa mod_d t1
        mwa #m_l1 t2
        adw t2 #$2
        ldx #15           ; 16 rows
ycol    ldy #35           ; 36 columns
xrow    lda (t1), y
        sta (t2), y
        dey
        bpl xrow
        ; increment src and targets, catering for the initial space
        adw t1 #36     ; src is only 36 bytes wide
        adw t2 #40     ; target is 40 bytes wide
        dex
        bpl ycol
        rts
        .endp
