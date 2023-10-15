        .export mh_s1, mh_s2, mh_h1
        .export md_s1, md_s2, md_h1
        .export mw_s1, mw_s2, mw_h1, mw_h2, mw_help_setup, mw_help_password, mw_custom_msg, mw_help_custom
        .export mx_s1, mx_s2, mx_h1, mx_m1, mx_m2
        .export mf_s1, mf_h1, mf_prev, mf_next, mf_copying_msg
        .export mf_host, mf_filter, mf_path

        .export     mw_bssid
        .export     mw_dns
        .export     mw_gateway
        .export     mw_hostname
        .export     mw_ip_addr
        .export     mw_mac
        .export     mw_netmask
        .export     mw_ssid
        .export     mw_nets_msg
        .export     mw_nets_msg2

        .include    "macros.inc"

; Data for screen display, help texts etc

.segment "SCR_DATA"

; ------------------------------------------------------------------
; Mod HOSTS data
; ------------------------------------------------------------------
mh_s1:
                INVERT_ATASCII
                .byte "HOST LIST", 0

mh_s2:
                NORMAL_CHARMAP
                .byte $81, $1e, $82
                INVERT_ATASCII
                .byte "Info                 Drive Slots"
                NORMAL_CHARMAP
                .byte $81, $1f, $82, 0

mh_h1:
                NORMAL_CHARMAP
                .byte $81, $1c, $1d, $82        ; endL up down endR
                INVERT_ATASCII
                .byte "Move "
                NORMAL_CHARMAP
                .byte $81, "E", $82
                INVERT_ATASCII
                .byte "Edit "
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "Browse", 0

; ------------------------------------------------------------------
; Mod DEVICES data
; ------------------------------------------------------------------
md_s1:
                INVERT_ATASCII
                .byte "DRIVE SLOTS", 0

md_s2:
                NORMAL_CHARMAP
                .byte $81, $1e, $82             ; arrow left surrounded by buffers
                INVERT_ATASCII
                .byte "Host List                   Wifi"
                NORMAL_CHARMAP
                .byte $81, $1f, $82, 0          ; arrow right surrounded by buffers

md_h1:
                NORMAL_CHARMAP
                .byte $81, $1c, $1d, $82        ; endL up down endR
                INVERT_ATASCII
                .byte "Move "
                NORMAL_CHARMAP
                .byte $81, "E", $82
                INVERT_ATASCII
                .byte "Eject", 0

; ------------------------------------------------------------------
; Mod WIFI data
; ------------------------------------------------------------------
mw_s1:
                INVERT_ATASCII
                .byte "WIFI SETUP", 0

mw_s2:
                NORMAL_CHARMAP
                .byte $81, $1e, $82
                INVERT_ATASCII
                .byte "Drive Slots                 Info"
                NORMAL_CHARMAP
                .byte $81, $1f, $82, 0

mw_h1:
                NORMAL_CHARMAP
                .byte $81, "S", $82
                INVERT_ATASCII
                .byte "Setup Wifi", 0

mw_h2:
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit"
                NORMAL_CHARMAP
                .byte $81, $1c, $1d, $82        ; endL up down endR
                INVERT_ATASCII
                .byte "Move "
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "Select", 0

mw_help_setup:
                NORMAL_CHARMAP
                .byte $81, $1c, $1d, $82        ; endL up down endR
                INVERT_ATASCII
                .byte "Move"
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "Select"
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0

mw_help_password:
                INVERT_ATASCII
                .byte "Enter SSID Password  "
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0
mw_help_custom:
                INVERT_ATASCII
                .byte "Enter Custom SSID  "
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0

mw_custom_msg:
                NORMAL_CHARMAP
                .byte "<Enter Custom SSID>", 0

; ------------------------------------------------------------------
; Mod DONE data
; ------------------------------------------------------------------
mx_s1:
                INVERT_ATASCII
                .byte "INFO", 0

mx_s2:
                NORMAL_CHARMAP
                .byte $81, $1e, $82
                INVERT_ATASCII
                .byte "Wifi                   Host List"
                NORMAL_CHARMAP
                .byte $81, $1f, $82, 0

mx_h1:          
                NORMAL_CHARMAP
                .byte $81, "OPTION", $82
                INVERT_ATASCII
                .byte "Mount Disks and Boot!", 0

                NORMAL_CHARMAP
mx_m1:          .byte "Config-NG by Fenrock", 0
mx_m2:          .byte "Version: 0.9.1", 0


; ------------------------------------------------------------------
; Mod FILES data
; ------------------------------------------------------------------

mf_s1:
                INVERT_ATASCII
                .byte "DISK IMAGES", 0

mf_copying_msg:
                INVERT_ATASCII
                .byte "COPYING! PICK DIR", 0

mf_h1:
                NORMAL_CHARMAP
                .byte $81, $1c, $1d, $82        ; endL up down endR
                INVERT_ATASCII
                .byte "Move"
                NORMAL_CHARMAP
                .byte $81, "<", $82
                INVERT_ATASCII
                .byte "Up"
                NORMAL_CHARMAP
                .byte $81, "N", $82
                INVERT_ATASCII
                .byte "New"
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "Select"
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0

                NORMAL_CHARMAP
mf_host:        .byte "Host:", 0
mf_filter:      .byte "Fltr:", 0
mf_path:        .byte "Path:", 0

mf_prev:
                NORMAL_CHARMAP
                .byte $81, $1e, $82
                INVERT_ATASCII
                .byte "Prev", 0

mf_next:
                INVERT_ATASCII
                .byte "Next"
                NORMAL_CHARMAP
                .byte $81, $1f, $82, 0

                NORMAL_CHARMAP
mw_ssid:        .byte "SSID:", 0
mw_hostname:    .byte "Hostname:", 0
mw_ip_addr:     .byte "IP Addr:", 0
mw_gateway:     .byte "Gateway:", 0
mw_dns:         .byte "DNS:", 0
mw_netmask:     .byte "Netmask:", 0
mw_mac:         .byte "MAC:", 0
mw_bssid:       .byte "BSSID:", 0

mw_nets_msg:    .byte "Fetching Networks", 0
mw_nets_msg2:   .byte "                 ", 0
