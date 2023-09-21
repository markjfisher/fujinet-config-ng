        .export     _reset_handler

        .import     _clr_scr_all
        .import     booting_mode
        .import     md_is_devices_data_fetched
        .import     mf_copying
        .import     mh_is_hosts_data_fetched
        .import     mod_current
        .import     mw_is_ac_data_fetched
        .import     mw_selected
        .import     start

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fc_mods.inc"
        .include    "atari.inc"

; needs to be in writable RAM to capture the DOSINI original vector
.segment "RESET"
.proc _reset_handler
        jsr     $ffff       ; overwritten by original DOSINI address

        ; reset all modules state, and clear old screen data
        mva     #Mod::init, mod_current
        mva     #$00, mh_is_hosts_data_fetched
        sta     md_is_devices_data_fetched
        sta     mw_is_ac_data_fetched
        sta     mw_selected
        sta     booting_mode
        sta     mf_copying

        jsr     _clr_scr_all
        jmp     start
.endproc