        .export     mw_setup_wifi

        .import     _fn_io_get_scan_result
        .import     _fn_io_scan_for_networks
        .import     fn_io_ssidinfo
        .import     get_scrloc
        .import     mw_net_count
        .import     pusha
        .import     put_s_p1p4

        .import     debug

        .include    "fc_zp.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"

.proc mw_setup_wifi
        ; read network scan

        jsr     _fn_io_scan_for_networks
        sta     mw_net_count

        ; TODO: test for error, show popup

        cmp     #MAX_NETS
        bcc     ok
        beq     ok

        ; we have room for 10 on screen
        mva     #10, mw_net_count

ok:
        ; loop over all the networks, and display their names for now
        ; screen location for first entry in ptr4
        ldx     #4
        ldy     #9
        jsr     get_scrloc
        mwa     ptr4, ptr3
        sbw1    ptr3, #4
        mva     #$00, tmp1              ; loop counter for networks

:       pusha   tmp1
        setax   #fn_io_ssidinfo
        jsr     _fn_io_get_scan_result

        mwa     {#(fn_io_ssidinfo + SSIDInfo::ssid)}, ptr1
        jsr     put_s_p1p4

        ; print all 3 bars, rub them out if power is low
        ldy     #$00    ; screen index for the wifi chars
        mva     #FNC_WIFI1, {(ptr3), y}
        iny
        mva     #FNC_WIFI2, {(ptr3), y}
        iny
        mva     #FNC_WIFI3, {(ptr3), y}

        lda     #$00            ; space char to overwrite the power values
        ldy     #$01            ; first char to erase
        ; print the signal strength. this is in SSIDInfo::rssi
        ; boundaries for 3 chars are:
        ; -40 = 3 bars
        ; -60 = 2 bars
        ; lower = 1 bar
        ldx     fn_io_ssidinfo + SSIDInfo::rssi
        bpl     bar3    ; any positive value is off the scale

        cpx     #$d9    ; -39
        bcs     bar3    ; -39 to -1  (> -40)
        cpx     #$c5    ; -59
        bcs     bar2    ; -59 to -40 (> -60)

; 1 bar, erase the 2nd bar
        sta     (ptr3), y
        ; run into erasing the 3rd bar
bar2:   iny
        sta     (ptr3), y

bar3:
        adw1    ptr4, #SCR_BYTES_W
        adw1    ptr3, #SCR_BYTES_W
        inc     tmp1
        lda     tmp1
        cmp     mw_net_count
        bne     :-

        rts
.endproc
