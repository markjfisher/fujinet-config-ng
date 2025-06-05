.export _cache

.export test_data_1
.export test_data_2
.export test_data_3
.export mock_bank_data
.export current_bank

.include    "page_cache.inc"

.bss

current_bank:           .res    1
mock_bank_data:         .res    16384     ; Space for testing bank operations

.data

; Cache structure starting empty with multiple banks for testing
_cache:                 .tag    page_cache

; Test data for insertions - different sizes for testing
test_data_1:
        .byte   $00, $01        ; Header: flags=0, num_entries=1
        ; 16 bytes of data
        .byte   $10, $11, $12, $13, $14, $15, $16, $17
        .byte   $18, $19, $1A, $1B, $1C, $1D, $1E, $1F

test_data_2:
        .byte   $00, $02        ; Header: flags=0, num_entries=2  
        ; 24 bytes of data
        .byte   $20, $21, $22, $23, $24, $25, $26, $27
        .byte   $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
        .byte   $30, $31, $32, $33, $34, $35, $36, $37

test_data_3:
        .byte   $01, $03        ; Header: flags=last_group, num_entries=3
        ; 32 bytes of data
        .byte   $40, $41, $42, $43, $44, $45, $46, $47
        .byte   $48, $49, $4A, $4B, $4C, $4D, $4E, $4F
        .byte   $50, $51, $52, $53, $54, $55, $56, $57
        .byte   $58, $59, $5A, $5B, $5C, $5D, $5E, $5F 