        .export     mfs_entries_cnt
        .export     mfs_entry_index
        .export     mfs_y_offset

        .include    "popup.inc"

.bss

; the current directory position value while browsing of first entry on screen
mfs_entry_index: .res 1
; the total number of entries on the current screen
mfs_entries_cnt: .res 1
; y offset for printing files
mfs_y_offset:    .res 1

