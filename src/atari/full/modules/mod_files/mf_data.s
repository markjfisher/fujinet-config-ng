        .export     mf_copying
        .export     mf_dir_or_file
        .export     mf_dir_pos
        .export     mf_selected

        .export     mf_ask_new_disk_cust_sector_size_val
        .export     mf_ask_new_disk_pu_msg
        .export     mf_ask_new_disk_std_info
        .export     mf_ask_new_disk_name_std
        .export     mf_ask_new_disk_name_cst
        .export     mf_ask_new_disk_sectors_cst
        .export     mf_ask_new_disk_std_sizes

        .export     mf_ask_new_disk_cst_info
        .export     mf_nd_std_h1

        .export     mf_fname_buf


        .include    "fn_data.inc"
        .include    "macros.inc"
        .include    "popup.inc"

.data
mf_copying:     .byte 0

.segment "BANK"
; temporary buffer for working with filenames
mf_fname_buf:   .res 256

.bss
; the current directory position value while browsing of first entry on screen
mf_dir_pos:     .res 2

; currently highlighted option
mf_selected:    .res 1

mf_dir_or_file: .res DIR_PG_CNT

mf_copy_from:   .res 2

; values for popups
mf_ask_new_disk_std_sizes_val:         .res 1
mf_ask_new_disk_cust_sector_size_val:  .res 1

.rodata

; STANDARD SIZE
mf_ask_new_disk_std_info:
                ; width, y-offset (4 shows path and bar), has_selectable, up/down option (size), l/r option index, edit index (name field)
                .byte 34, 4, 1, 3, $ff, 0


mf_ask_new_disk_name_std:
                ; num, len, #string buffer (val), #title location
                .byte PopupItemType::string, 1, 64, $ff, $ff, 20, <mf_ask_new_disk_name_msg, >mf_ask_new_disk_name_msg

                .byte PopupItemType::space

                ; "Disk Size:"
                .byte PopupItemType::text, 1, <mf_size_msg, >mf_size_msg

mf_ask_new_disk_std_sizes:
                ; num, len (chars), val, texts (non-zero terminated)
                .byte PopupItemType::textList, 6, 5, <mf_ask_new_disk_std_sizes_val, >mf_ask_new_disk_std_sizes_val, <mf_ask_new_disk_std_sizes_str, >mf_ask_new_disk_std_sizes_str, 12

                .byte PopupItemType::space
                .byte PopupItemType::space
                .byte PopupItemType::text, 1, <mf_press_c_msg, >mf_press_c_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

mfs_size_std    = * - mf_ask_new_disk_std_info

; CUSTOM SIZE - Complicated by having 2 editable strings, but probably not used enough to annoy people they have to tab to 2nd editable field
mf_ask_new_disk_cst_info:
                ; width, y-offset, has_selectable, up/down option (sector size), l/r option index (none), edit index (name field)
                .byte 34, 4, 1, 5, $ff, 0

mf_ask_new_disk_name_cst:
                ; num, len, val, #title_text, #string_loc, vpWidth
                .byte PopupItemType::string, 1, 64, $ff, $ff, 20, <mf_ask_new_disk_name_msg, >mf_ask_new_disk_name_msg

                .byte PopupItemType::space

mf_ask_new_disk_sectors_cst:
                ; largest value is "65535" so 5 chars+nul = 6
                ; num, len, val, #title_text, #string_loc
                .byte PopupItemType::number, 1, 5, $ff, $ff, 5, <mfs_nd_cust_sector_count_name_msg, >mfs_nd_cust_sector_count_name_msg

                .byte PopupItemType::space
                ; "Sector Size:"
                .byte PopupItemType::text, 1, <mfs_sector_size_msg, >mfs_sector_size_msg


mf_ask_new_disk_cust_sector_size:
                .byte PopupItemType::textList, 3, 3, <mf_ask_new_disk_cust_sector_size_val, >mf_ask_new_disk_cust_sector_size_val, <mf_ask_new_disk_cust_sector_size_txt, >mf_ask_new_disk_cust_sector_size_txt, 15

                .byte PopupItemType::space
                .byte PopupItemType::space
                .byte PopupItemType::space
                .byte PopupItemType::text, 1, <mf_press_n_msg, >mf_press_n_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

; not used anywhere, but good to know how to use * to get a size
mfs_size_cst    = * - mf_ask_new_disk_cst_info

mf_ask_new_disk_pu_msg:
                .byte "Create New Disk", 0

mf_ask_new_disk_name_msg:
                .byte "Name: ", 0

mfs_nd_cust_sector_count_name_msg:
                .byte "    Sectors: ", 0

mf_ask_new_disk_std_sizes_str:
                .byte "  90k"
                .byte " 130k"
                .byte " 180k"
                .byte " 360k"
                .byte " 720k"
                .byte "1440k"

mf_size_msg:
                .byte "Disk Size:", 0

mfs_sector_size_msg:
                .byte "Sector Size:", 0

mf_ask_new_disk_cust_sector_size_txt:
                .byte "128"
                .byte "256"
                .byte "512"

mf_press_c_msg:
                NORMAL_CHARMAP
                .byte "    ", $01
                INVERT_ATASCII
                .byte "Press C for Custom Size"
                NORMAL_CHARMAP
                .byte $02, 0

mf_press_n_msg:
                NORMAL_CHARMAP
                .byte "    ", $01
                INVERT_ATASCII
                .byte "Press N for Normal Size"
                NORMAL_CHARMAP
                .byte $02, 0

mf_nd_std_h1:
                NORMAL_CHARMAP
                .byte $81, $1c, $1d     ; arrows
                .byte $84               ; tween
                NORMAL_CHARMAP
                .byte "E", $82
                INVERT_ATASCII
                .byte "Edit"
                NORMAL_CHARMAP
                .byte $81, "TAB", $82
                INVERT_ATASCII
                .byte "Next"
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "OK"
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0