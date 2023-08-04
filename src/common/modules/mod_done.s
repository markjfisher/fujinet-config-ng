        .export     mod_done
        .import     mod_current, _fn_io_set_boot_config
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"

.proc mod_done
        lda     #$00    ; disable config
        jsr     _fn_io_set_boot_config
        mva     #Mod::exit, mod_current
        rts
.endproc