        .export     mfs_entries_cnt
        .export     mfs_entry_index
        .export     mfs_is_eod
        .export     mfs_kbh_running
        .export     mfs_y_offset
        .export     mfs_size_cst
        .export     mfs_size_std

        .export     mfs_ask_new_disk_pu_msg
        .export     mfs_ask_new_disk_std_info
        .export     mfs_ask_new_disk_name_std
        .export     mfs_ask_new_disk_name_cst
        .export     mfs_ask_new_disk_sectors_cst
        .export     mfs_ask_new_disk_std_sizes

        .export     mfs_ask_new_disk_cst_info

        .import     fn_io_buffer

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

;; not setting these, will reuse fn_io_buffer to save 42 bytes of memory that's almost never used
; mfs_ask_new_disk_name_std_val:          .res 18 ; TODO: do we need 1 more char?
; mfs_ask_new_disk_name_cst_val:          .res 18
; mfs_ask_new_disk_sectors_cst_val:       .res 6

mfs_ask_new_disk_std_sizes_val:         .res 1
mfs_ask_new_disk_cust_sector_size_val:  .res 1

.rodata

; STANDARD SIZE
mfs_ask_new_disk_std_info:
                ; width, y-offset, has_selectable, up/down option (size), l/r option index, edit index (name field)
                .byte 34, 2, 1, 3, $ff, 0

mfs_ask_new_disk_name_std:
                ; num, len, #string buffer (val), #title location
                .byte PopupItemType::string, 1, 27, $ff, $ff, <mfs_ask_new_disk_name_msg, >mfs_ask_new_disk_name_msg

                .byte PopupItemType::space

                ; "Disk Size:"
                .byte PopupItemType::text, 1, <mfs_size_msg, >mfs_size_msg

mfs_ask_new_disk_std_sizes:
                ; num, len (chars), val, texts (non-zero terminated)
                .byte PopupItemType::textList, 6, 5, <mfs_ask_new_disk_std_sizes_val, >mfs_ask_new_disk_std_sizes_val, <mfs_ask_new_disk_std_sizes_str, >mfs_ask_new_disk_std_sizes_str, 12

                .byte PopupItemType::space
                .byte PopupItemType::finish

mfs_size_std    = * - mfs_ask_new_disk_std_info

; CUSTOM SIZE - Complicated by having 2 editable strings, but probably not used enough to annoy people they have to tab to 2nd editable field
mfs_ask_new_disk_cst_info:
                ; width, y-offset, has_selectable, up/down option (sector size), l/r option index (none), edit index (name field)
                .byte 34, 2, 1, 4, $ff, 0

mfs_ask_new_disk_name_cst:
                ; num, len, val, #title_text, #string_loc
                .byte PopupItemType::string, 1, 27, $ff, $ff, <mfs_ask_new_disk_name_msg, >mfs_ask_new_disk_name_msg

                .byte PopupItemType::space

mfs_ask_new_disk_sectors_cst:
                ; num, len, val, #title_text, #string_loc
                .byte PopupItemType::string, 1, 10, $ff, $ff, <mfs_nd_cust_sector_count_name_msg, >mfs_nd_cust_sector_count_name_msg

                ; "Sector Size:"
                .byte PopupItemType::text, 1, <mfs_sector_size_msg, >mfs_sector_size_msg


mfs_ask_new_disk_cust_sector_size:
                .byte PopupItemType::textList, 3, 3, <mfs_ask_new_disk_cust_sector_size_val, >mfs_ask_new_disk_cust_sector_size_val, <mfs_ask_new_disk_cust_sector_size_txt, >mfs_ask_new_disk_cust_sector_size_txt, 15

                .byte PopupItemType::finish

mfs_size_cst    = * - mfs_ask_new_disk_cst_info

.segment "SCR_DATA"

mfs_ask_new_disk_pu_msg:
                .byte "Create New Disk", 0

mfs_ask_new_disk_name_msg:
                .byte "Name: ", 0

mfs_nd_cust_sector_count_name_msg:
                .byte "    Sectors: ", 0

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
