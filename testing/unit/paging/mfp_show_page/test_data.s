.export _cng_prefs
.export _find_params
.export _get_pagegroup_params
.export empty_help
.export empty_last_page
.export fake_bank_data
.export fake_cache_entry
.export full_last_page
.export full_not_last_page
.export mf_dir_or_file
.export mf_dir_pg_cnt
.export mf_dir_pos
.export mf_entries_cnt
.export mf_entry_index
.export mf_is_eod
.export mf_selected
.export mf_y_offset
.export show_next_calls
.export size_output
.export ts_output

.include "cng_prefs.inc"
.include "page_cache.inc"

.bss
mf_dir_pos:         .res 2
mf_dir_pg_cnt:      .res 1
mf_entries_cnt:     .res 1
mf_entry_index:     .res 1
mf_selected:        .res 1
mf_y_offset:        .res 1
mf_is_eod:          .res 1
mf_dir_or_file:     .res 18
show_next_calls:    .res 1
_cng_prefs:         .tag CNG_PREFS_DATA
_get_pagegroup_params:
                    .tag page_cache_get_pagegroup_params
_find_params:       .tag page_cache_find_params

.data
ts_output:          .byte "01/01/1970 00:00", 0
size_output:        .byte "         0", 0
empty_help:         .byte "          ", 0

full_last_page:
        .byte $01, 16       ; flags=legacy last_group, num_entries=16
.repeat 16, I
        .byte $00, $00, $00, $00      ; packed timestamp and flags
        .byte $00, $00, $00           ; file size
        .byte $00                     ; media type
        .byte 'A' + I, $00            ; one-character filename
.endrepeat
full_last_page_end:

FULL_LAST_PAGE_SIZE = full_last_page_end - full_last_page

full_not_last_page:
        .byte $00, 16       ; flags=not last_group, num_entries=16
.repeat 16, I
        .byte $00, $00, $00, $00      ; packed timestamp and flags
        .byte $00, $00, $00           ; file size
        .byte $00                     ; media type
        .byte 'a' + I, $00            ; one-character filename
.endrepeat

empty_last_page:
        .byte $80, 0        ; flags=last_group, num_entries=0

fake_cache_entry:
        .word $0000         ; path_hash
        .byte $01           ; group_id
        .byte $00           ; bank_id
        .word $0000         ; bank_offset
        .word $0002         ; group_size

fake_bank_data:
        .byte $80, 0        ; cached next pagegroup header: empty EOD marker
