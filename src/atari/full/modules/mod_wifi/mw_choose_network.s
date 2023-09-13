        .export mw_choose_network

        .import     _clr_help
        .import     _edit_line
        .import     _fc_strncpy
        .import     _fn_io_get_scan_result
        .import     _put_help
        .import     fn_io_netconfig
        .import     fn_io_ssidinfo
        .import     get_scrloc
        .import     mw_help_password
        .import     mw_save_ssid
        .import     mw_selected
        .import     pusha
        .import     pushax
        .import     put_s_p1p4
        .import     return1

        .include    "fc_zp.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

.proc mw_choose_network
        jsr     _clr_help
        put_help   #0, #mw_help_password

        ; This is the same as entering the SSID manually, just filled in for us.
        ; Copy the SSID to netconfig, then ask for a password
        ; we need to regrab the data for the selected entry to get its name again. It's on screen, but the config needs reloading
        pusha   mw_selected
        setax   #fn_io_ssidinfo
        jsr     _fn_io_get_scan_result

        pushax  {#(fn_io_netconfig + NetConfig::ssid)}
        pushax  {#(fn_io_ssidinfo + SSIDInfo::ssid)}
        lda     #32
        jsr     _fc_strncpy

        ldx     #$00
        ldy     #20             ; password line
        jsr     get_scrloc

        ; display current password
        mwa     {#(fn_io_netconfig + NetConfig::password)}, ptr1
        jsr     put_s_p1p4

        ; get the password - 64 means the borders will break, minor issue
        pushax  ptr1
        pushax  ptr4
        lda     #64
        jsr     _edit_line
        beq     esc_bssid

        jmp     mw_save_ssid

esc_bssid:
        jmp     return1

.endproc