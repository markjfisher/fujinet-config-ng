        .export     mod_init
        .import     _fn_io_get_wifi_enabled, _fn_io_get_wifi_status, _fn_io_get_ssid, _dev_init
        .import     mod_current, host_selected, current_line, device_selected, done_is_booting
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

; void mod_init()

; First Module to load when application starts.
; Calls out to device specific initialisation.
; Nothing in these modules should be machine specific.
; All _fn_* routines will be implemented per device
.proc mod_init
        jsr     _dev_init               ; call device specific initialization

        ; initialise some module values
        mva     #$00, host_selected
        sta     device_selected
        sta     current_line
        sta     done_is_booting

        ; Start getting information from FN to decide what module to load next
        jsr     _fn_io_get_wifi_enabled
        beq     not_enabled

        jsr     _fn_io_get_wifi_status
        cmp     #WifiStatus::connected
        beq     connected

        jsr     _fn_io_get_ssid
        setax   ptr1                    ; SSIDInfo in ptr1
        ldy     #SSIDInfo::ssid
        lda     (ptr1), y               ; get first char from ssid of SSIDInfo
        beq     set_wifi                ; if it's 0, there's no SSID information available, so need to setup wifi

        ; fall through to wifi (this is "connect wifi", but same module as "set wifi" - maybe simplify logic, as ssid doesn't matter here)
        mva     #Mod::wifi, mod_current
        rts

not_enabled:
        mva     #Mod::hosts, mod_current
        rts

connected:
        mva     #Mod::hosts, mod_current
        rts

set_wifi:
        mva     #Mod::wifi, mod_current
        rts

.endproc