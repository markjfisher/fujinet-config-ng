        .export         _main
        .import         run_module, mod_current
        .include        "fn_macros.inc"
        .include        "fn_mods.inc"

.proc _main
:       jsr     run_module

        ; are we done?
        lda     mod_current
        cmp     #Mod::exit
        bne     :-

        rts
.endproc
