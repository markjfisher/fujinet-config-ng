        .export     run_module
        .import     mod_table, mod_current

; executes code for the selected module
.proc run_module
        jsr     call_module
        rts

call_module:
        ; stack based dispatch to jump to appropriate module handler
        lda     mod_current
        asl
        tax
        lda     mod_table+1, x
        pha
        lda     mod_table, x
        pha
        rts     ; JMP! rts in the module will return to previous caller

.endproc