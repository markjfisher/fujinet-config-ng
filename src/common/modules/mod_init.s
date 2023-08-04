        .export     mod_init
        .import     _fn_io_get_host_slots, _fn_io_get_wifi_enabled, _fn_io_get_wifi_status, _fn_io_get_ssid
        .import     pushax, _fn_put_s, _setup_screen, mod_current
        .include    "zeropage.inc"
        .include    "fn_io.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"

.proc mod_init
        jsr     _setup_screen

        jsr     show_init

        jsr     _fn_io_get_wifi_enabled
        beq     not_enabled

        jsr     _fn_io_get_wifi_status
        cmp     #WifiStatus::connected
        beq     connected

        jsr     _fn_io_get_ssid
        setax   ptr1                ; SSIDInfo in ptr1
        ldy     #SSIDInfo::ssid
        lda     (ptr1), y           ; get first char from ssid of SSIDInfo
        beq     set_wifi

        ; fall through to connect wifi
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

show_init:
        ; won't be on screen long, but show initialising messages
        put_s   #10, #7, #s_init1

        rts

.endproc

.rodata
s_init1:    .byte "Initialising...", 0
