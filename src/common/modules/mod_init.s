        .export     _mod_init
        .export     fc_connected

        .import     _read_prefs
        .import     _dev_init
        .import     _fuji_get_ssid
        .import     _fuji_get_wifi_enabled
        .import     _fuji_get_wifi_status
        .import     booting_mode
        .import     fuji_netconfig
        .import     kb_current_line
        .import     md_device_selected
        .import     mh_host_selected
        .import     mi_selected
        .import     mod_current
        .import     mw_selected

        .import     debug

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fujinet-fuji.inc"
        .include    "modules.inc"
        .include    "atari.inc"

.segment "CODE2"

; void _mod_init()
;
; First Module to load when application starts.
; Connects to wifi if possible, and moves to first screen module
.proc _mod_init
        lda     #$00
        sta     SDMCTL                  ; turn off the screen to minimize flashing etc

        ; read stored app state from appkeys - these are used by code called in dev_init
        jsr     _read_prefs

        ; call device specific initialization
        jsr     _dev_init

        ; initialise some module values
        mva     #$00, mh_host_selected
        sta     md_device_selected
        sta     mi_selected
        sta     mw_selected
        sta     kb_current_line
        sta     booting_mode
        sta     fc_connected

        ; Start getting information from FN to decide what module to load next
        jsr     _fuji_get_wifi_enabled
        beq     not_enabled

        setax   #tmp1                   ; use tmp1 for results of call
        jsr     _fuji_get_wifi_status
        lda     tmp1
        cmp     #WifiStatus::connected
        beq     connected

        ; only runs if we aren't connected, which is rare
        setax   #fuji_netconfig
        jsr     _fuji_get_ssid
        setax   ptr1                    ; NetConfig in ptr1
        ldy     #NetConfig::ssid
        lda     (ptr1), y               ; get first char from ssid of NetConfig
        beq     set_wifi                ; if it's 0, there's no SSID information available, so need to setup wifi

        ; fall through to wifi (this is "connect wifi", but same module as "set wifi" - maybe simplify logic, as ssid doesn't matter here)
        mva     #Mod::wifi, mod_current
        rts

not_enabled:
        mva     #Mod::hosts, mod_current
        rts

connected:
        mva     #$01, fc_connected
        mva     #Mod::hosts, mod_current
        rts

set_wifi:
        mva     #Mod::wifi, mod_current
        rts

.endproc

.segment "BANK"
fc_connected:   .res 1
