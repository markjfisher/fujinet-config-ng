        .export     mod_init
        .import     _fn_io_get_host_slots, _fn_io_get_wifi_enabled, _fn_io_get_wifi_status, _fn_io_get_ssid, _dev_init
        .import     pushax, _fn_put_s, _fn_setup_screen, mod_current, _fn_put_c
        .include    "zeropage.inc"
        .include    "fn_io.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"

.proc mod_init
        jsr     _dev_init

        put_c   #'1', 2, 15
        jsr     _fn_io_get_wifi_enabled
        beq     not_enabled

        put_c   #'2', 3, 15
        jsr     _fn_io_get_wifi_status
        cmp     #WifiStatus::connected
        beq     connected

        put_c   #'3', 4, 15
        jsr     _fn_io_get_ssid
        setax   ptr1                ; SSIDInfo in ptr1
        ldy     #SSIDInfo::ssid
        lda     (ptr1), y           ; get first char from ssid of SSIDInfo
        beq     set_wifi

        ; fall through to connect wifi
        put_c   #'4', 5, 15
        mva     #Mod::wifi, mod_current
        rts

not_enabled:
        put_c   #'x', 10, 15
        mva     #Mod::hosts, mod_current
        rts

connected:
        put_c   #'y', 11, 15
        mva     #Mod::hosts, mod_current
        rts

set_wifi:
        put_c   #'z', 12, 15
        mva     #Mod::wifi, mod_current
        rts

.endproc
