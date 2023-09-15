        .export         _main
        .import         run_module
        .include        "fc_macros.inc"
        .include        "fc_mods.inc"

.proc _main
:       jsr     run_module

        clc
        bcc     :-

        rts
.endproc
