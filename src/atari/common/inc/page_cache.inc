PAGE_CACHE_MAX_ENTRIES = 255    ; Maximum number of entries in cache
BANK_SIZE              = $4000  ; Size of each bank in bytes (16KB)

; Size of page_cache_entry_t for memmove calculations
PAGE_CACHE_ENTRY_SIZE = 8      ; Each entry is 8 bytes

.struct page_cache_entry
    path_hash       .word   ; 2 bytes - hash of the path string
    group_id        .byte   ; 1 byte  - page group ID
    bank_id         .byte   ; 1 byte  - bank where data is stored
    bank_offset     .word   ; 2 bytes - offset within bank
    group_size      .word   ; 2 bytes - size of the page group data (includes 2 extra bytes from header)
.endstruct

.struct page_cache
    max_banks       .byte       ; total banks allowed to use in caching code
    entry_count     .byte       ; Number of active entries
    entries         .res 255*8  ; Array of page_cache_entry (255 entries * 8 bytes each)
    bank_free_space .res 64*2   ; Array of bank free space (max of 64 banks * 2 bytes each)
.endstruct

.struct page_cache_find_params
    path_hash       .word   ; 2 bytes - hash to search for
    group_id        .byte   ; 1 byte  - group ID to search for
    found_exact     .byte   ; 1 byte  - output: 1 if exact match found
    position        .byte   ; 1 byte  - output: position where found or should be inserted
    entry_loc       .word   ; 2 bytes - location in cache::entries for this find, matched or not
.endstruct

.struct page_cache_insert_params
    path_hash       .word   ; 2 bytes - hash of the path string
    group_id        .byte   ; 1 byte  - page group ID
    bank_id         .byte   ; 1 byte  - bank where data is stored
    bank_offset     .word   ; 2 bytes - offset within bank
    group_size      .word   ; 2 bytes - size of the page group data
    data_ptr        .word   ; 2 bytes - pointer to source data
    pg_flags        .byte   ; 1 byte  - the page group's flags from its header
    pg_entry_cnt    .byte   ; 1 byte  - number of entries in the page group from header
    success         .byte   ; 1 byte  - output: 1 if insert successful
.endstruct

.struct page_cache_remove_group_params
    path_hash       .word   ; 2 bytes - hash of the path string
    group_id        .byte   ; 1 byte  - page group ID
    success         .byte   ; 1 byte  - output: 1 if insert successful
.endstruct

.struct page_cache_find_bank_params
    size_needed     .word   ; 2 bytes - size needed for allocation
    path_hash       .word   ; 2 bytes - path hash to try to match
    bank_id         .byte   ; 1 byte  - output: selected bank (0xFF if none found)
.endstruct

.struct page_cache_remove_path_params
    path_hash       .word   ; 2 bytes - hash of the path string
    removed_count   .byte   ; 1 byte  - output: number of entries removed
.endstruct

.struct page_cache_get_pagegroup_params
    dir_position    .word   ; 2 bytes - fujinet position for first file viewed in the page. 0 indexed, and then a multiple of the page_size
    page_size       .byte   ; number of entries (files/dirs) in a page
    data_ptr        .word   ; location to save pagegroup data to
    fetching_cb     .word   ; callback routine when fetching data, e.g. "loading" screen. X will be 0 for start, 1 for end
.endstruct

.struct page_cache_set_path_filter_params
    path            .word   ; pointer to path
    filter          .word   ; pointer to any filter applied to results
    path_hash       .word   ; output location for hash
.endstruct

.struct page_cache_pagegroup_header
    flags           .byte    ; bit 7: last group (1=yes) - not used
    num_entries     .byte    ; if not last group, will be page_size - not used
    data_size       .word    ; amount of data excluding header for this pagegroup
    group_id        .byte    ; 0 based index for pagegroup for hash_path
.endstruct