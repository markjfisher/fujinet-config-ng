        .export         _main

        .import         mod_current
        .import         run_module

        .include        "modules.inc"

.proc _main
:       jsr     run_module

        ; are we quitting?
        lda     mod_current
        cmp     #Mod::exit
        bne     :-
.endproc
