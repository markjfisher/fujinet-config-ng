BANK_SIZE              = $4000  ; Size of each bank in bytes (16KB)
PAGE_CACHE_MAX_ENTRIES = $FF    ; we are keeping counts simple, and only allow 255 cache index entries
PAGE_CACHE_ENTRY_SIZE = 8       ; Each index entry is 8 bytes long, used for moving over the index entries

.struct page_cache_entry
    path_hash       .word   ; 2 bytes - hash of the path string
    group_id        .byte   ; 1 byte - page group ID
    bank_id         .byte   ; 1 byte - bank where data is stored
    bank_offset     .word   ; 2 bytes - offset within bank
    group_size      .word   ; 2 bytes - size of the page group data
.endstruct

.struct page_cache
    entry_count     .byte       ; Number of active entries
    entries         .res 258*8  ; Array of page_cache_entry (8 bytes each)
    bank_free_space .res 64*2   ; Array of bank free space (64 banks max * 2 bytes each)
.endstruct

; we can't consolidate the memory for parameters, as sometimes the find needs to remove items
; to make space, and it then needs to have different values to the find, which then loses the
; original values. keeping those values and then restoring them after a deletion
; is more code than just having 2 different parameter blocks. so we keep things simple.
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
