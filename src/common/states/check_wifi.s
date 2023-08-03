        .export     check_wifi
        .import     app_state
        .import     _fn_io_get_wifi_enabled, _fn_io_get_wifi_status, _fn_io_get_ssid
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_state.inc"

.proc check_wifi
        jsr     _fn_io_get_wifi_enabled
        beq     not_enabled

        jsr     _fn_io_get_wifi_status
        cmp     #3
        beq     connected

        jsr     _fn_io_get_ssid
        setax   ptr1                ; SSIDInfo in ptr1
        ldy     #SSIDInfo::ssid
        lda     (ptr1), y           ; get first char from ssid of SSIDInfo
        beq     set_wifi

        ; fall through to connect wifi
        mva     #AppState::connect_wifi, app_state
        rts

not_enabled:
        mva     #AppState::hosts_and_devices, app_state
        rts

connected:
        mva     #AppState::hosts_and_devices, app_state
        rts

set_wifi:
        mva     #AppState::set_wifi, app_state
        rts

.endproc

