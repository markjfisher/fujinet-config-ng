        .export     mf_dir_or_file
        .export     mf_dir_pos
        .export     mf_selected

        .include    "fn_data.inc"

.bss

; the current directory position value while browsing of first entry on screen
mf_dir_pos:     .res 2

; currently highlighted option
mf_selected:    .res 1

mf_dir_or_file: .res DIR_PG_CNT
