.export     _find_params
.export     _insert_params
.export     _remove_group_params
.export     _remove_path_params
.export     _set_path_flt_params
.export     _get_pagegroup_params
.export     _find_bank_params
.export     page_cache_buf
.export     entry_loc
.export     bank_id
.export     entry_index
.export     num_pgs
.export     page_header
.export     entry_offset
.export     end_offset
.export     highest_offset
.export     move_size
.export     group_size
.export     adjust_size
.export     attempts

.include    "page_cache.inc"

.segment "BANK"

; Parameter blocks for various operations
_find_params:           .tag    page_cache_find_params
_insert_params:         .tag    page_cache_insert_params
_remove_group_params:   .tag    page_cache_remove_group_params
_remove_path_params:    .tag    page_cache_remove_path_params
_set_path_flt_params:   .tag    page_cache_set_path_filter_params
_get_pagegroup_params:  .tag    page_cache_get_pagegroup_params
_find_bank_params:      .tag    page_cache_find_bank_params

page_header:            .tag    page_cache_pagegroup_header

; Shared variables
entry_loc:              .res    2       ; Location of current entry
bank_id:                .res    1       ; Current bank number
entry_index:            .res    1       ; Current entry index
num_pgs:                .res    1       ; Number of page groups
entry_offset:           .res    2       ; Current entry offset
end_offset:             .res    2       ; End offset for calculations
highest_offset:         .res    2       ; Highest offset found
move_size:              .res    2       ; Size of data to move
group_size:             .res    2       ; Size of current group
adjust_size:            .res    2       ; Size to adjust by
attempts:               .res    1       ; Number of attempts for operations

; this can't be in BANK as it's used for the data returned from fujinet, and then copied into
; cache, which is in RAM BANK, so won't be available to copy between
.bss
page_cache_buf:         .res    2048    ; Buffer for temporary storage
