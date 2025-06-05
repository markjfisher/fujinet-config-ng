.export _cache
.export _find_bank_params
.export _remove_path_params

.export remove_path_called
.export remove_path_hash_low
.export remove_path_hash_high

.include "page_cache.inc"
.include "zeropage.inc"

.segment "DATA"

; Parameters for find_bank
_find_bank_params:
        .tag page_cache_find_bank_params

; Parameters for remove path
_remove_path_params:
        .tag page_cache_remove_path_params

; Variables to track mock calls
remove_path_called:    .res    1       ; Set to 1 when remove_path is called
remove_path_hash_low:  .res    1       ; Captures hash low byte passed to remove_path
remove_path_hash_high: .res    1       ; Captures hash high byte passed to remove_path

; Cache data with two entries
_cache:
        .byte   64              ; max_banks
        .byte   2               ; entry_count
        .word   $4000           ; bank_size (default 16KB)
        ; First entry
        .byte   $12, $34       ; path_hash ($1234)
        .byte   1              ; group_id
        .byte   1              ; bank_id
        .word   0              ; bank_offset
        .word   0              ; group_size
        ; Second entry
        .byte   $56, $78       ; path_hash ($5678)
        .byte   2              ; group_id
        .byte   2              ; bank_id
        .word   0              ; bank_offset
        .word   0              ; group_size
        ; Remaining entries
        .res    253*8          ; remaining entries
        .res    64*2           ; bank_free_space

