        .export mw_choose_network

        .import     _clr_help
        .import     _fc_strncpy
        .import     _fuji_get_scan_result
        .import     _put_help
        .import     _scr_clr_highlight
        .import     fuji_netconfig
        .import     fuji_ssidinfo
        .import     mw_help_password
        .import     mw_selected
        .import     mw_ssid_pass_pu
        .import     pusha
        .import     pushax

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "modules.inc"
        .include    "popup.inc"

; ptr1,ptr4
.proc mw_choose_network
        jsr     _clr_help
        jsr     _scr_clr_highlight
        put_help   #0, #mw_help_password

        ; This is the same as entering the SSID manually, just filled in for us.
        ; Copy the SSID to netconfig, then ask for a password
        ; we need to regrab the data for the selected entry to get its name again. It's on screen, but the config needs reloading
        pusha   mw_selected
        setax   #fuji_ssidinfo
        jsr     _fuji_get_scan_result

        pushax  {#(fuji_netconfig + NetConfig::ssid)}
        pushax  {#(fuji_ssidinfo + SSIDInfo::ssid)}
        lda     #32
        jsr     _fc_strncpy

        jmp     mw_ssid_pass_pu

.endproc