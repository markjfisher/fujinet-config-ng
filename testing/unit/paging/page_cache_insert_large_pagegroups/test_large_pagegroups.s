.export _main
.export init
.export test_240
.export test_240_end
.export test_256
.export test_256_end
.export test_272
.export test_272_end
.export _change_bank
.export _get_bank_base
.export _set_default_bank

.import _cache
.import _insert_params
.import _page_cache_insert
.import _page_cache_init
.import _page_cache_set_bank_size
.import test_pagegroup_240
.import test_pagegroup_256
.import test_pagegroup_272
.import mock_bank_data
.import current_bank

.include "page_cache.inc"
.include "zp.inc"

.segment "CODE2"

; Mock bank switching functions
.proc _change_bank
        ; A contains bank_id - store it for our mock
        sta     current_bank
        rts
.endproc

.proc _set_default_bank
        lda     #$FF
        sta     current_bank
        rts
.endproc

.proc _get_bank_base
        ; For our test, return the base of our mock bank data
        lda     #<mock_bank_data
        ldx     #>mock_bank_data
        rts
.endproc

; Initialize test data
.proc init_test_data
        ; Set bank size to 2K
        lda     #$00        ; Low byte of bank size
        ldx     #$08        ; High byte of bank size ($0800 = 2048 bytes)
        jsr     _page_cache_set_bank_size

        ; Initialize cache with 1 bank
        lda     #$01
        jsr     _page_cache_init
        rts
.endproc

; Main test entry point
_main:
init:
        ; Initialize test data
        jsr     init_test_data

test_240:
        ; Insert first pagegroup (240 bytes data + 2 header = 242 total)
        ; Set up insert parameters
        lda     #$34        ; path_hash low byte
        sta     _insert_params+page_cache_insert_params::path_hash
        lda     #$12        ; path_hash high byte  
        sta     _insert_params+page_cache_insert_params::path_hash+1

        lda     #$00        ; group_id
        sta     _insert_params+page_cache_insert_params::group_id

        ; group_size = 242 bytes (0xF2)
        lda     #$F2
        sta     _insert_params+page_cache_insert_params::group_size
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_size+1

        ; data_ptr = test_pagegroup_240
        lda     #<test_pagegroup_240
        sta     _insert_params+page_cache_insert_params::data_ptr
        lda     #>test_pagegroup_240
        sta     _insert_params+page_cache_insert_params::data_ptr+1

        ; pg_flags and pg_entry_cnt from data
        lda     test_pagegroup_240      ; flags
        sta     _insert_params+page_cache_insert_params::pg_flags
        lda     test_pagegroup_240+1    ; num_entries  
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        jsr     _page_cache_insert
test_240_end:

test_256:
        ; Insert second pagegroup (256 bytes data + 2 header = 258 total)
        ; Same path_hash, different group_id
        lda     #$34        ; path_hash low byte
        sta     _insert_params+page_cache_insert_params::path_hash
        lda     #$12        ; path_hash high byte
        sta     _insert_params+page_cache_insert_params::path_hash+1

        lda     #$01        ; group_id
        sta     _insert_params+page_cache_insert_params::group_id

        ; group_size = 258 bytes (0x102) 
        lda     #$02
        sta     _insert_params+page_cache_insert_params::group_size
        lda     #$01
        sta     _insert_params+page_cache_insert_params::group_size+1

        ; data_ptr = test_pagegroup_256
        lda     #<test_pagegroup_256
        sta     _insert_params+page_cache_insert_params::data_ptr
        lda     #>test_pagegroup_256
        sta     _insert_params+page_cache_insert_params::data_ptr+1

        ; pg_flags and pg_entry_cnt from data
        lda     test_pagegroup_256      ; flags
        sta     _insert_params+page_cache_insert_params::pg_flags
        lda     test_pagegroup_256+1    ; num_entries
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        jsr     _page_cache_insert
test_256_end:

test_272:
        ; Insert third pagegroup (272 bytes data + 2 header = 274 total)
        ; This is the critical test - bank_offset will be > 255!
        ; Previous insertions: 242 + 258 = 500 bytes (0x1F4)
        lda     #$34        ; path_hash low byte
        sta     _insert_params+page_cache_insert_params::path_hash
        lda     #$12        ; path_hash high byte
        sta     _insert_params+page_cache_insert_params::path_hash+1

        lda     #$02        ; group_id
        sta     _insert_params+page_cache_insert_params::group_id

        ; group_size = 274 bytes (0x112)
        lda     #$12
        sta     _insert_params+page_cache_insert_params::group_size
        lda     #$01
        sta     _insert_params+page_cache_insert_params::group_size+1

        ; data_ptr = test_pagegroup_272
        lda     #<test_pagegroup_272
        sta     _insert_params+page_cache_insert_params::data_ptr
        lda     #>test_pagegroup_272
        sta     _insert_params+page_cache_insert_params::data_ptr+1

        ; pg_flags and pg_entry_cnt from data
        lda     test_pagegroup_272      ; flags
        sta     _insert_params+page_cache_insert_params::pg_flags
        lda     test_pagegroup_272+1    ; num_entries
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        jsr     _page_cache_insert
test_272_end:

        ; Infinite loop to keep test running
        jmp     test_272_end 