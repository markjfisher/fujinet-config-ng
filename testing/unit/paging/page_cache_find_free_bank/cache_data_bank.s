.export     _cache
.export     _find_bank_params

.include    "page_cache.inc"

.bss
_find_bank_params:
        .tag page_cache_find_bank_params

.data
; Test cache with 3 banks, some entries and varying free space
_cache:
        .byte   3               ; max_banks = 3
        .byte   3               ; entry_count = 3 entries
        .word   $4000           ; bank_size (default 16KB)

        ; entries array (3 entries, 8 bytes each)
        ; First entry: hash $12,$34 in bank 0
        .byte   $12,$34         ; path_hash
        .byte   $00            ; group_id (not used in this test)
        .byte   $00            ; bank_id = 0
        .word   $0000          ; bank_offset
        .word   $1000          ; group_size = 4KB

        ; Second entry: hash $23,$45 in bank 1
        .byte   $23,$45         ; path_hash
        .byte   $00            ; group_id
        .byte   $01            ; bank_id = 1
        .word   $0000          ; bank_offset
        .word   $2000          ; group_size = 8KB

        ; Third entry: hash $34,$56 in bank 2
        .byte   $34,$56         ; path_hash
        .byte   $00            ; group_id
        .byte   $02            ; bank_id = 2
        .word   $0000          ; bank_offset
        .word   $3000          ; group_size = 12KB

        ; Pad to ensure bank_free_space is at correct offset
        .res    255*8-24       ; Pad entries array (255*8 total - 3 entries * 8 bytes)

        ; bank_free_space array (3 banks * 2 bytes each)
        .word   $3000          ; bank 0: 12KB free
        .word   $2000          ; bank 1: 8KB free
        .word   $1000          ; bank 2: 4KB free

        ; Pad remaining bank space array
        .res    61*2           ; Pad remaining bank space (64 total - 3 banks)
