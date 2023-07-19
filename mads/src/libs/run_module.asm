;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run_module
;
; this will execute any code for the current module

        .reloc
        .public run_module
        .extrn copy_to_screen .proc
        .extrn mod_table, mod_d, i_opt .word

run_module      .proc
        jsr call_module
        copy_to_screen
        rts

call_module
        ; call the code of the current module
        ; Stack based dispatch - pushes address of routine to stack and uses 'rts' to do the actual JMP
        lda i_opt
        asl
        tax
        lda mod_table + 1, x
        pha
        lda mod_table, x
        pha
        rts ; JMP!
        ; the rts in the module will return to previous caller

        .endp