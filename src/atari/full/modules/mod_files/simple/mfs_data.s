        .export     mfs_entries_cnt
        .export     mfs_entry_index
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

