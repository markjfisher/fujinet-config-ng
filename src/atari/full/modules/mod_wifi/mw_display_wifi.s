        .export     _mw_display_wifi

        .import     _put_s
        .import     mw_adapter_config
        .import     mw_bssid
        .import     mw_dns
        .import     mw_gateway
        .import     mw_hostname
        .import     mw_ip_addr
        .import     mw_mac
        .import     mw_netmask
        .import     mw_ssid
        .import     mw_version
        .import     pusha

        .include    "zp.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "macros.inc"

; void mw_display_wifi()
;
; prints adapter config information stored in mw_adapter_config
.proc _mw_display_wifi

        put_s   #05, #0, #mw_ssid
        put_s   #01, #1, #mw_hostname
        put_s   #02, #2, #mw_ip_addr
        put_s   #02, #3, #mw_gateway
        put_s   #06, #4, #mw_dns
        put_s   #02, #5, #mw_netmask
        put_s   #06, #6, #mw_mac
        put_s   #04, #7, #mw_bssid
        ; put_s   #07, #8, #mw_version

        put_s   #11, #0, {#(mw_adapter_config + AdapterConfigExtended::ssid)}
        put_s   #11, #1, {#(mw_adapter_config + AdapterConfigExtended::hostname)}
        put_s   #11, #2, {#(mw_adapter_config + AdapterConfigExtended::sLocalIP)}
        put_s   #11, #3, {#(mw_adapter_config + AdapterConfigExtended::sGateway)}
        put_s   #11, #4, {#(mw_adapter_config + AdapterConfigExtended::sDnsIP)}
        put_s   #11, #5, {#(mw_adapter_config + AdapterConfigExtended::sNetmask)}
        put_s   #11, #6, {#(mw_adapter_config + AdapterConfigExtended::sMacAddress)}
        put_s   #11, #7, {#(mw_adapter_config + AdapterConfigExtended::sBssid)}
        ; put_s   #16, #8, {#(mw_adapter_config + AdapterConfigExtended::fn_version)}

        ; there are 13 lines in the lower box to use

        rts
.endproc
