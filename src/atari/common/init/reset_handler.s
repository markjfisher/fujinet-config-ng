        .export     _reset_handler
        ; .export     reset_debug

        .import     _clr_scr_all
        .import     booting_mode
        .import     fc_connected
        .import     kb_current_line
        .import     md_device_selected
        .import     md_is_devices_data_fetched
        .import     mf_copying
        .import     mh_host_selected
        .import     mh_is_hosts_data_fetched
        .import     mi_selected
        .import     mod_current
        .import     mw_is_ac_data_fetched
        .import     mw_selected
        .import     start

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "atari.inc"

; needs to be in writable RAM to capture the DOSINI original vector
.segment "RESET"

; .proc reset_debug
;         rts
; .endproc

.proc _pre_reset
        mva     #$00, COLDST
        ; jmp     reset_debug
        rts
.endproc

.proc _reset_handler
        jsr     _pre_reset
        jsr     $ffff       ; overwritten by original DOSINI address

        ; reset all modules state, and clear old screen data
        mva     #Mod::init, mod_current
        mva     #$00, mh_is_hosts_data_fetched
        sta     md_is_devices_data_fetched
        sta     mw_is_ac_data_fetched
        sta     mw_selected
        sta     mh_host_selected
        sta     mi_selected
        sta     booting_mode
        sta     mf_copying
        sta     md_device_selected
        sta     kb_current_line
        sta     fc_connected

        jsr     _clr_scr_all

        jmp     start
.endproc