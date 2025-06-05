.export _cache
.export _find_params
.export entry_loc

.include "page_cache.inc"

.segment "DATA"

; Parameters for find operation
_find_params:
        .tag page_cache_find_params

; Cache data with three entries in sorted order for testing find_position
_cache:
        .byte   1               ; max_banks = 1
        .byte   3               ; entry_count = 3
        .word   $4000           ; bank_size (default 16KB)
        
        ; Entry 0: hash=$1234, group_id=0
        .byte   $12, $34        ; path_hash
        .byte   $00             ; group_id
        .byte   $00             ; bank_id
        .word   $0000           ; bank_offset
        .word   $0020           ; group_size
        
        ; Entry 1: hash=$2345, group_id=0 (between $1234 and $3456)
        .byte   $23, $45        ; path_hash
        .byte   $00             ; group_id
        .byte   $00             ; bank_id
        .word   $0020           ; bank_offset
        .word   $0030           ; group_size
        
        ; Entry 2: hash=$3456, group_id=0
        .byte   $34, $56        ; path_hash
        .byte   $00             ; group_id
        .byte   $00             ; bank_id
        .word   $0050           ; bank_offset
        .word   $0040           ; group_size
        
        ; Remaining entries (252 entries * 8 bytes each)
        .res    252*8
        
        ; Bank free space array (64 banks * 2 bytes each)
        .res    64*2

; Shared variables needed by find_position and calc_entry_loc
entry_loc:              .res    2       ; Location of current entry 