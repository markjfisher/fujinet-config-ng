;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run_module
;
; this will execute any code for the current module

        .reloc
        .public run_module
        ;.extrn m_l1 .word                       ; top of the display memory where 
        .extrn copy_to_screen .proc
        .extrn mod_table, mod_d, i_opt .word
        ;.extrn t1, t2 .byte

run_module      .proc
        jsr call_module
        copy_to_screen
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