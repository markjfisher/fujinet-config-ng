        .export     _mod_exit

        .import     _mx_do_exit
        .import     _mx_init_screen
        .import     mod_current

        .include    "fc_macros.inc"
        .include    "fc_mods.inc"

.proc _mod_exit
        jsr     _mx_init_screen
        jsr     _mx_do_exit

        ; if we drop into here, we didn't manage to boot, so display an error and return us to hosts
        ; TODO: error message
        mva     #Mod::hosts, mod_current
        rts

.endproc
