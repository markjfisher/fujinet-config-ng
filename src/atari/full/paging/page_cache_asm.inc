BANK_SIZE              = $4000  ; Size of each bank in bytes (16KB)
PAGE_CACHE_MAX_ENTRIES = 512    ; a single bank has 16k - 128 bytes, divide by 8 allows 2032 entries, so 512 very short of this for now

; Size of page_cache_entry_t for memmove calculations
PAGE_CACHE_ENTRY_SIZE = 8      ; Each entry is 8 bytes

.struct page_cache_entry
    path_hash       .word   ; 2 bytes - hash of the path string
    group_id        .byte   ; 1 byte - page group ID
    bank_id         .byte   ; 1 byte - bank where data is stored
    bank_offset     .word   ; 2 bytes - offset within bank
    group_size      .word   ; 2 bytes - size of the page group data
.endstruct

.struct page_cache
    entries         .res 512*8  ; Array of page_cache_entry (8 bytes each)
    bank_free_space .res 64*2   ; Array of bank free space (64 banks max * 2 bytes each)
.endstruct

.struct page_cache_find_params
    path_hash       .word   ; 2 bytes - hash to search for
    group_id        .byte   ; 1 byte - group ID to search for
    found_exact     .byte   ; 1 byte - output: 1 if exact match found
    position        .byte   ; 1 byte - output: position where found or should be inserted
.endstruct

.struct page_cache_insert_params
    path_hash       .word   ; 2 bytes - hash of the path string
    group_id        .byte   ; 1 byte - page group ID
    bank_id         .byte   ; 1 byte - bank where data is stored
    bank_offset     .word   ; 2 bytes - offset within bank
    group_size      .word   ; 2 bytes - size of the page group data
    success         .byte   ; 1 byte - output: 1 if insert successful
.endstruct

.struct page_cache_remove_group_params
    path_hash       .word   ; 2 bytes - hash of the path string
    group_id        .byte   ; 1 byte - page group ID
    success         .byte   ; 1 byte - output: 1 if insert successful
.endstruct

.struct page_cache_find_bank_params
    size_needed     .word   ; 2 bytes - size needed for allocation
    path_hash       .word   ; 2 bytes - path hash to try to match
    bank_id         .byte   ; 1 byte - output: selected bank (0xFF if none found)
.endstruct

.struct page_cache_remove_path_params
    path_hash       .word   ; 2 bytes - hash of the path string
    removed_count   .byte   ; 1 byte - output: number of entries removed
.endstruct
