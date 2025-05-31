.export _cache
.export test_cache
.export _find_params
.export entry_loc

.include    "page_cache.inc"

.bss

; Find parameters structure
_find_params:
        .tag    page_cache_find_params

entry_loc:      .res 2


.data

; Cache structure with space for all entries
; Initial cache state with 3 entries
_cache:
test_cache:
        .byte   $04     ; max_banks = 4
        .byte   $03     ; entry_count = 3
        
        ; Entry 1: path_hash=$1234, group_id=0, bank_id=1, offset=$100, size=$20
        .byte   $12, $34   ; path_hash
        .byte   $00     ; group_id
        .byte   $01     ; bank_id
        .word   $0100   ; bank_offset
        .word   $0020   ; group_size

        ; Entry 2: path_hash=$2345, group_id=0, bank_id=2, offset=$200, size=$20
        .byte   $23, $45   ; path_hash
        .byte   $00     ; group_id
        .byte   $02     ; bank_id
        .word   $0200   ; bank_offset
        .word   $0020   ; group_size

        ; Entry 3: path_hash=$3456, group_id=0, bank_id=3, offset=$300, size=$20
        .byte   $34, $56   ; path_hash
        .byte   $00     ; group_id
        .byte   $03     ; bank_id
        .word   $0300   ; bank_offset
        .word   $0020   ; group_size

        ; Remaining entries are unused
        .res   252*8    ; 252 more entries (255 total - 3 used)
        
        ; bank_free_space array (64 banks * 2 bytes each)
        .word   $4000   ; Bank 0: all free
        .word   $3FE0   ; Bank 1: used 32 bytes
        .word   $3FE0   ; Bank 2: used 32 bytes
        .word   $3FE0   ; Bank 3: used 32 bytes
        .res    60*2    ; Remaining banks all free

; Sample page groups - each with one file entry
pg_data1:
        .byte   $00     ; Flags: not last group
        .byte   $01     ; 1 entry
        ; File entry for "/dir1/file1.txt"
        .byte   $35     ; Year 2023 (53 years since 1970)
        .byte   $0C     ; December (month 12)
        .byte   $58     ; Day 11, hour high bits 3
        .byte   $20     ; Hour low bits 0, minute 32
        .byte   $10, $20, $00  ; Size: 8208 bytes
        .byte   $00     ; Media type: unknown
        .byte   "file1.txt", $00

pg_data2:
        .byte   $00     ; Flags: not last group
        .byte   $01     ; 1 entry
        ; File entry for "/dir2/file2.txt"
        .byte   $35     ; Year 2023
        .byte   $0C     ; December
        .byte   $58     ; Day 11, hour high bits 3
        .byte   $20     ; Hour low bits 0, minute 32
        .byte   $20, $30, $00  ; Size: 12320 bytes
        .byte   $00     ; Media type: unknown
        .byte   "file2.txt", $00

pg_data3:
        .byte   $00     ; Flags: not last group
        .byte   $01     ; 1 entry
        ; File entry for "/dir3/file3.txt"
        .byte   $35     ; Year 2023
        .byte   $0C     ; December
        .byte   $58     ; Day 11, hour high bits 3
        .byte   $20     ; Hour low bits 0, minute 32
        .byte   $30, $40, $00  ; Size: 16432 bytes
        .byte   $00     ; Media type: unknown
        .byte   "file3.txt", $00

