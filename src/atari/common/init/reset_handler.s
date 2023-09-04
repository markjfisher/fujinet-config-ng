        .export     _reset_handler
        .import     start, mod_current, _clr_scr_all, hosts_fetched, devices_fetched
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "atari.inc"

; needs to be in writable RAM to capture the DOSINI original vector
.segment "RESET"
.proc _reset_handler
        jsr     $ffff       ; overwritten by original DOSINI address

        ; reset all modules state, and clear old screen data
        mwa     #Mod::init, mod_current
        mwa     #$00, hosts_fetched
        mwa     #$00, devices_fetched
        jsr     _clr_scr_all
        jmp     start
.endproc