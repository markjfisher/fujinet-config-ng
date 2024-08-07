        .export     _mod_boot

        .import     _mx_do_boot
        .import     _mx_error_booting
        .import     _mx_init_screen
        .import     mod_current

        .include    "macros.inc"
        .include    "modules.inc"

.proc _mod_boot
        jsr     _mx_init_screen
        jsr     _mx_do_boot

        ; if we drop into here, we didn't manage to boot, so display an error and return us to hosts
        jsr     _mx_error_booting

        mva     #Mod::hosts, mod_current
        rts

.endproc
