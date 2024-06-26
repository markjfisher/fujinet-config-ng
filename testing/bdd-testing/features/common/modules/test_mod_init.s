        .export         _main
        .export         mod_current, _fuji_get_wifi_enabled, _fuji_get_wifi_status, _fuji_get_ssid, _dev_init
        .export         t_wifi_enabled, t_wifi_status, t_ssid_fetched, t_ssid_info
        .import         _mod_init, setax

        .include        "macros.inc"
        .include        "fujinet-fuji.inc"

.proc _main
        ; call the function under test
        jmp     _mod_init
.endproc

; -----------------------------------------
; mock the external functions
.proc _fuji_get_wifi_enabled
        ldx     #$00
        lda     t_wifi_enabled
        rts
.endproc

; TODO: needs fixing
.proc _fuji_get_wifi_status
        ldx     #$00
        lda     t_wifi_status
        rts
.endproc

.proc _fuji_get_ssid
        ; set ax to t_ssid_info and fill it with some data depending on t_ssid_fetched
        ; we just need a non-zero value, so just store t_ssid_fetched directly in first byte
        mva     t_ssid_fetched, t_ssid_info
        setax   #t_ssid_info
        rts
.endproc

.proc _dev_init
        lda     #$01
        sta     $80
        rts
.endproc

.bss

mod_current:    .res 1
t_wifi_enabled: .res 1
t_wifi_status:  .res 1
t_ssid_fetched: .res 1
t_ssid_info:    .tag SSIDInfo
