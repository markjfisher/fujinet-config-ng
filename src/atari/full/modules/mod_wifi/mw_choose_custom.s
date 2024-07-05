        .export     mw_choose_custom

        .import     _clr_help
        .import     _edit_line
        .import     _fc_strncpy
        .import     _fuji_get_scan_result
        .import     _put_help
        .import     _scr_clr_highlight
        .import     _show_select
        .import     fuji_netconfig
        .import     fuji_ssidinfo
        .import     get_scrloc
        .import     mw_ask_custom_wifi_pass_info
        .import     mw_ask_custom_wifi_pu_msg
        .import     mw_ask_custom_wifi_ssid_info
        .import     mw_ask_cutom_wifi_info
        .import     mw_help_custom
        .import     mw_help_password
        .import     mw_save_ssid
        .import     mw_selected
        .import     pu_null_cb
        .import     pusha
        .import     pushax
        .import     put_s_p1p4
        .import     return1

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "modules.inc"
        .include    "popup.inc"

;ptr1,ptr4
.proc mw_choose_custom
        jsr     _clr_help
;         put_help   #0, #mw_help_custom

;         ldx     #$00
;         lda     mw_selected
;         clc
;         adc     #9                      ; adjust for top section
;         tay
;         jsr     get_scrloc              ; ptr4 = edit location

;         ; blank the line that read "<Enter Custom SSID>"
;         lda     #$00            ; we know this is screen for space, conveniently 0 for setting y
;         tay
; :       sta     (ptr4), y
;         iny
;         cpy     #38
;         bne     :-

;         ; string location is fuji_netconfig::ssid
;         ; first print it to screen if it's got a value, to allow user to continue editing previous value
;         mwa     {#(fuji_netconfig + NetConfig::ssid)}, ptr1
;         jsr     put_s_p1p4

;         ; -----------------------------------------------------------------
;         ; BSSID
;         pushax  ptr1
;         pushax  ptr4
;         lda     #32
;         jsr     _edit_line

;         ; return value = 1 for changed, 0 for ESC
;         beq     esc_bssid

;         ; a host name was provided, now need a password, use next line. print any value we have in our NetConfig mem
;         jsr     _clr_help
;         put_help   #0, #mw_help_password

;         adw1    ptr4, #SCR_BYTES_W
;         mwa     {#(fuji_netconfig + NetConfig::password)}, ptr1
;         jsr     put_s_p1p4

;         ; -----------------------------------------------------------------
;         ; PASSWORD
;         pushax  ptr1
;         pushax  ptr4
;         lda     #64                     ; TODO: make the edit field cope with long strings on screen. this will trash borders
;         jsr     _edit_line
;         beq     esc_bssid

        ; we set both, so save them back to FN

        ; ------------------------------------------------------------
        ; NEW popup for ssid / password custom setting


        ; remove highlight
        jsr     _scr_clr_highlight

        ; our current fuji_netconfig struct can be used to hold the data being edited, no malloc needed
        mwa     {#(fuji_netconfig + NetConfig::ssid)}, { mw_ask_custom_wifi_ssid_info + POPUP_VAL_IDX }
        mwa     {#(fuji_netconfig + NetConfig::password)}, { mw_ask_custom_wifi_pass_info + POPUP_VAL_IDX }

        pushax  #pu_null_cb
        pushax  #mw_ask_cutom_wifi_info
        pushax  #mw_help
        setax   #mw_ask_custom_wifi_pu_msg
        jsr     _show_select

        cmp     #PopupItemReturn::escape
        beq     esc_bssid

        ; details accepted, try them
        jmp     mw_save_ssid

esc_bssid:
        jmp     return1

mw_help:
        jsr     _clr_help
        put_help   #0, #mw_help_password
        rts

.endproc
