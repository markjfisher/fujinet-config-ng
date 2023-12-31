        .export     _mod_init
        .export     fc_connected

        .import     _dev_init
        .import     _fn_io_get_ssid
        .import     _fn_io_get_wifi_enabled
        .import     _fn_io_get_wifi_status
        .import     booting_mode
        .import     fn_io_netconfig
        .import     kb_current_line
        .import     md_device_selected
        .import     mh_host_selected
        .import     mod_current

        .import     debug

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_io.inc"
        .include    "modules.inc"

; void _mod_init()
;
; First Module to load when application starts.
; Connects to wifi if possible, and moves to first screen module
.proc _mod_init
        jsr     _dev_init               ; call device specific initialization

        ; initialise some module values
        mva     #$00, mh_host_selected
        sta     md_device_selected
        sta     kb_current_line
        sta     booting_mode
        sta     fc_connected

        ; Start getting information from FN to decide what module to load next
        jsr     _fn_io_get_wifi_enabled
        beq     not_enabled

        jsr     _fn_io_get_wifi_status
        cmp     #WifiStatus::connected
        beq     connected

        ; only runs if we aren't connected, which is rare
        setax   #fn_io_netconfig
        jsr     _fn_io_get_ssid
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

.bss
fc_connected:   .res 1
