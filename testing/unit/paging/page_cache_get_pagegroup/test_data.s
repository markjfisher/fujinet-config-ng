.export _cache

.export invalid_fn_data
.export mock_bank_data
.export mock_fn_block
.export mock_fn_block_9abc
.export test_buffer
.export current_bank

.include    "page_cache.inc"

.bss

current_bank:           .res    1
test_buffer:            .res    256
mock_bank_data:         .res    16384     ; Space for 4 test regions (initial 2 + new 2)

.data

; Cache structure starting empty with a single bank
_cache:                 .tag    page_cache

; Mock fujinet directory block data for initial cache setup
mock_fn_block:
        .byte   'M', 'F'    ; Magic marker
        .byte   $04         ; Header size
        .byte   $02         ; Number of pagegroups

        ; First pagegroup
        .byte   $00         ; Flags
        .byte   $01         ; Num entries
        .byte   $20, $00    ; Data size (32 bytes) - explicitly little-endian
        .byte   $00         ; Group ID
        ; Data
        .byte   $00, $01, $02, $03, $04, $05, $06, $07
        .byte   $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
        .byte   $10, $11, $12, $13, $14, $15, $16, $17
        .byte   $18, $19, $1A, $1B, $1C, $1D, $1E, $1F

        ; Second pagegroup
        .byte   $01         ; Flags (last group)
        .byte   $02         ; Num entries
        .byte   $30, $00    ; Data size (48 bytes) - explicitly little-endian
        .byte   $01         ; Group ID
        ; Data
        .byte   $20, $21, $22, $23, $24, $25, $26, $27
        .byte   $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
        .byte   $30, $31, $32, $33, $34, $35, $36, $37
        .byte   $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
        .byte   $40, $41, $42, $43, $44, $45, $46, $47
        .byte   $48, $49, $4A, $4B, $4C, $4D, $4E, $4F

; Mock fujinet directory block data for 9ABC search
mock_fn_block_9abc:
        .byte   'M', 'F'    ; Magic marker
        .byte   $04         ; Header size
        .byte   $02         ; Number of pagegroups

        ; First pagegroup
        .byte   $00         ; Flags
        .byte   $01         ; Num entries
        .word   $0020       ; Data size
        .byte   $00         ; Group ID
        ; Data
        .byte   $50, $51, $52, $53, $54, $55, $56, $57
        .byte   $58, $59, $5A, $5B, $5C, $5D, $5E, $5F
        .byte   $60, $61, $62, $63, $64, $65, $66, $67
        .byte   $68, $69, $6A, $6B, $6C, $6D, $6E, $6F

        ; Second pagegroup
        .byte   $01         ; Flags (last group)
        .byte   $02         ; Num entries
        .word   $0030       ; Data size
        .byte   $01         ; Group ID
        ; Data
        .byte   $70, $71, $72, $73, $74, $75, $76, $77
        .byte   $78, $79, $7A, $7B, $7C, $7D, $7E, $7F
        .byte   $80, $81, $82, $83, $84, $85, $86, $87
        .byte   $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
        .byte   $90, $91, $92, $93, $94, $95, $96, $97
        .byte   $98, $99, $9A, $9B, $9C, $9D, $9E, $9F

; Mock fujinet data with invalid header
invalid_fn_data:
        .byte   'X', 'Y'    ; Wrong magic marker
        .byte   $04         ; Header size
        .byte   $02         ; Number of pagegroups 