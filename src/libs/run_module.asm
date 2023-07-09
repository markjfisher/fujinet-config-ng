;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run_module
;
; this will execute any code for the current module

        .reloc
        .public run_module
        .extrn m_l1, mod_table, mod_d, i_opt .word
        .extrn t1, t2 .byte

run_module      .proc
        jsr call_module

        ; copy 38x16 bytes from mod_d to m_l1+2
        mwa mod_d t1
        mwa #m_l1 t2
        adw t2 #$2
        ldx #15           ; rows
ycol    ldy #35           ; columns
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

call_module
        ; call the module, allows it to set mod_d to 36x16 data to show
        lda i_opt
        asl
        tax
        lda mod_table + 1, x
        pha
        lda mod_table, x
        pha
        rts             ; Stack based dispatch - THIS DOES A JMP to mod_table address for current index
        ; the rts in the module will return to previous caller

        .endp