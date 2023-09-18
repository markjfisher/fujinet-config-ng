        .export     mf_dir_or_file
        .export     mf_dir_pos
        .export     mf_selected

        .export     mf_ask_new_disk_pu_msg
        .export     mf_ask_new_disk_std_info
        .export     mf_ask_new_disk_name_std
        .export     mf_ask_new_disk_name_cst
        .export     mf_ask_new_disk_sectors_cst
        .export     mf_ask_new_disk_std_sizes

        .export     mf_ask_new_disk_cst_info


        .include    "fn_data.inc"
        .include    "popup.inc"

.bss

; the current directory position value while browsing of first entry on screen
mf_dir_pos:     .res 2

; currently highlighted option
mf_selected:    .res 1

mf_dir_or_file: .res DIR_PG_CNT


.rodata

; values for popups

mf_ask_new_disk_std_sizes_val:         .res 1
mf_ask_new_disk_cust_sector_size_val:  .res 1

; STANDARD SIZE
mf_ask_new_disk_std_info:
                ; width, y-offset (4 shows path and bar), has_selectable, up/down option (size), l/r option index, edit index (name field)
                .byte 34, 4, 1, 3, $ff, 0

mf_ask_new_disk_name_std:
                ; num, len, #string buffer (val), #title location
                .byte PopupItemType::string, 1, 27, $ff, $ff, <mf_ask_new_disk_name_msg, >mf_ask_new_disk_name_msg

                .byte PopupItemType::space

                ; "Disk Size:"
                .byte PopupItemType::text, 1, <mfs_size_msg, >mfs_size_msg

mf_ask_new_disk_std_sizes:
                ; num, len (chars), val, texts (non-zero terminated)
                .byte PopupItemType::textList, 6, 5, <mf_ask_new_disk_std_sizes_val, >mf_ask_new_disk_std_sizes_val, <mf_ask_new_disk_std_sizes_str, >mf_ask_new_disk_std_sizes_str, 12

                .byte PopupItemType::space
                .byte PopupItemType::finish

mfs_size_std    = * - mf_ask_new_disk_std_info

; CUSTOM SIZE - Complicated by having 2 editable strings, but probably not used enough to annoy people they have to tab to 2nd editable field
mf_ask_new_disk_cst_info:
                ; width, y-offset, has_selectable, up/down option (sector size), l/r option index (none), edit index (name field)
                .byte 34, 4, 1, 4, $ff, 0

mf_ask_new_disk_name_cst:
                ; num, len, val, #title_text, #string_loc
                .byte PopupItemType::string, 1, 27, $ff, $ff, <mf_ask_new_disk_name_msg, >mf_ask_new_disk_name_msg

                .byte PopupItemType::space

mf_ask_new_disk_sectors_cst:
                ; num, len, val, #title_text, #string_loc
                .byte PopupItemType::string, 1, 10, $ff, $ff, <mfs_nd_cust_sector_count_name_msg, >mfs_nd_cust_sector_count_name_msg

                ; "Sector Size:"
                .byte PopupItemType::text, 1, <mfs_sector_size_msg, >mfs_sector_size_msg


mf_ask_new_disk_cust_sector_size:
                .byte PopupItemType::textList, 3, 3, <mf_ask_new_disk_cust_sector_size_val, >mf_ask_new_disk_cust_sector_size_val, <mf_ask_new_disk_cust_sector_size_txt, >mf_ask_new_disk_cust_sector_size_txt, 15

                .byte PopupItemType::finish

mfs_size_cst    = * - mf_ask_new_disk_cst_info

.segment "SCR_DATA"

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

mfs_size_msg:
                .byte "Disk Size:", 0

mfs_sector_size_msg:
                .byte "Sector Size:", 0

mf_ask_new_disk_cust_sector_size_txt:
                .byte "128"
                .byte "256"
                .byte "512"
