        .export md_s1, md_s2, md_h1
        .export mx_s1, mx_s3, mx_h1, mx_m1, mx_m2
        .export mh_s1, mh_s2, mh_h1
        .export mw_s1, mw_s2, mw_h1
        .export mf_s1, mf_h1, mf_h2
        .export mf_host, mf_filter, mf_path

        .include    "fn_macros.inc"

; Data for screen display, help texts etc

.segment "SCREEN"

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
                .byte "Host List              Info/Exit"
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
; Mod HOSTS data
; ------------------------------------------------------------------
mh_s1:
                INVERT_ATASCII
                .byte "HOST LIST", 0

mh_s2:
                NORMAL_CHARMAP
                .byte $81, $1e, $82
                INVERT_ATASCII
                .byte "Info/Exit            Drive Slots"
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
; Mod DONE data
; ------------------------------------------------------------------
mx_s1:
                INVERT_ATASCII
                .byte "INFO / EXIT", 0

mx_s3:
                NORMAL_CHARMAP
                .byte $81, $1e, $82
                INVERT_ATASCII
                .byte "Drive Slots            Host List"
                NORMAL_CHARMAP
                .byte $81, $1f, $82, 0

mx_h1:          
                NORMAL_CHARMAP
                .byte $81, "OPTION", $82
                INVERT_ATASCII
                .byte "Mount Disks and Boot!", 0

                NORMAL_CHARMAP
mx_m1:          .byte "Config-NG by Fenrock", 0
mx_m2:          .byte "Version: 0.8.1", 0


; ------------------------------------------------------------------
; Mod FILES data
; ------------------------------------------------------------------

mf_s1:
                INVERT_ATASCII
                .byte "DISK IMAGES", 0

mf_h1:
                NORMAL_CHARMAP
                .byte $81, $1c, $1d, $82        ; endL up down endR
                INVERT_ATASCII
                .byte "Move "
                NORMAL_CHARMAP
                .byte $81, "<", $82
                INVERT_ATASCII
                .byte "Up Dir  "
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "Choose", 0

mf_h2:
                NORMAL_CHARMAP
                .byte $81, $1e, $1f, $82
                INVERT_ATASCII
                .byte "Prev/Next Pg   "
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0

                NORMAL_CHARMAP
mf_host:        .byte "Host:", 0
mf_filter:      .byte "Fltr:", 0
mf_path:        .byte "Path:", 0

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
                .byte "Drive Slots            Info/Exit", 0
                NORMAL_CHARMAP
                .byte $81, $1f, $82, 0

mw_h1:
                NORMAL_CHARMAP
                .byte "TODO", 0