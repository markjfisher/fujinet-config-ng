        .export     mfs_entries_cnt
        .export     mfs_entry_index
        .export     mfs_is_eod
        .export     mfs_kbh_running
        .export     mfs_y_offset

        .include    "popup.inc"

.bss

; the current directory position value while browsing of first entry on screen
mfs_entry_index: .res 1
; the total number of entries on the current screen
mfs_entries_cnt: .res 1
; y offset for printing files
mfs_y_offset:    .res 1
; flag to say if we are already in a global kbh or not, so we don't recurse into it when entering a sub-dir
mfs_kbh_running: .res 1
; flag to indicate if we are on EOD
mfs_is_eod:      .res 1

; values for popups
mfs_ask_new_disk_name_std_val:          .res 1
mfs_ask_new_disk_std_sizes_val:         .res 1
mfs_ask_new_disk_name_cst_val:          .res 1
mfs_ask_new_disk_sectors_cst_val:       .res 1
mfs_ask_new_disk_cust_sector_size_val:  .res 1

.rodata

; both popups are the size size, so we don't worry about screen corruption between them

; STANDARD SIZE
mfs_ask_new_disk_info_std:
                ; width, y-offset, has_selectable, up/down option (size), l/r option index
                .byte 28, 2, 1, 0, 3, $ff

mfs_ask_new_disk_name_std:
                ; num, len, val, #title_text, #string_loc
                .byte PopupItemType::string, 1, 18, <mfs_ask_new_disk_name_std_val, >mfs_ask_new_disk_name_std_val, <mfs_ask_new_disk_name_msg, >mfs_ask_new_disk_name_msg

                .byte PopupItemType::space

                ; "Disk Size:"
                .byte PopupItemType::text, 1, <mfs_size_msg, >mfs_size_msg

mfs_ask_new_disk_std_sizes:
                ; num, len (chars), val, texts (non-zero terminated)
                .byte PopupItemType::textList, 6, 5, <mfs_ask_new_disk_std_sizes_val, >mfs_ask_new_disk_std_sizes_val, <mfs_ask_new_disk_std_sizes_str, >mfs_ask_new_disk_std_sizes_str

                .byte PopupItemType::finish



; CUSTOM SIZE
mfs_ask_new_disk_info_cst:
                ; width, y-offset, has_selectable, up/down option (none), l/r option index
                .byte 28, 2, 1, 0, 5, $ff

mfs_ask_new_disk_name_cst:
                ; num, len, val, #title_text, #string_loc
                .byte PopupItemType::string, 1, 18, <mfs_ask_new_disk_name_cst_val, >mfs_ask_new_disk_name_cst_val, <mfs_ask_new_disk_name_msg, >mfs_ask_new_disk_name_msg

                .byte PopupItemType::space

mfs_ask_new_disk_sectors_cst:
                ; num, len, val, #title_text, #string_loc
                .byte PopupItemType::string, 1, 8, <mfs_ask_new_disk_sectors_cst_val, >mfs_ask_new_disk_sectors_cst_val, <mfs_nd_cust_sector_count_name_msg, >mfs_nd_cust_sector_count_name_msg

                .byte PopupItemType::space

                ; "Sector Size:"
                .byte PopupItemType::text, 1, <mfs_sector_size_msg, >mfs_sector_size_msg


mfs_ask_new_disk_cust_sector_size:
                .byte PopupItemType::textList, 3, 3, <mfs_ask_new_disk_cust_sector_size_val, >mfs_ask_new_disk_cust_sector_size_val, <mfs_ask_new_disk_cust_sector_size_txt, >mfs_ask_new_disk_cust_sector_size_txt

                .byte PopupItemType::finish


.segment "SCR_DATA"

mfs_ask_new_disk_name_msg:
                .byte "Name:    ", 0

mfs_nd_cust_sector_count_name_msg:
                .byte "Sectors: ", 0

mfs_ask_new_disk_std_sizes_str:
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

mfs_ask_new_disk_cust_sector_size_txt:
                .byte "128"
                .byte "256"
                .byte "512"
