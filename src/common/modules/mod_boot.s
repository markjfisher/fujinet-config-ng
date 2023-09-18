        .export     _mod_boot

        .import     _mx_do_boot
        .import     _mx_error_booting
        .import     _mx_init_screen
        .import     mod_current

        .include    "fc_macros.inc"
        .include    "fc_mods.inc"

.proc _mod_boot
        jsr     _mx_init_screen
        jsr     _mx_do_boot

        ; if we drop into here, we didn't manage to boot, so display an error and return us to hosts
        ; TODO: error message

        jsr     _mx_error_booting

        mva     #Mod::hosts, mod_current
        rts

.endproc
