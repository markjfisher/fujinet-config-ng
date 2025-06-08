.export _main
.export t1
.export t2
.export t3
.export t4
.export t5
.export t6
.export t1_end
.export t2_end
.export t3_end
.export t4_end
.export t5_end
.export t6_end
.export _change_bank
.export _get_bank_base
.export _set_default_bank

.import test_data_1
.import test_data_2
.import test_data_3
.import mock_bank_data
.import current_bank
.import _cache
.import _page_cache_insert
.import _page_cache_init
.import _page_cache_set_bank_size
.import _insert_params

.include "zp.inc"
.include "macros.inc"
.include "page_cache.inc"

.segment "CODE"

; Initialize test data
.proc init_test_data
        ; Set small bank size for testing (256 bytes)
        lda     #$00            ; Low byte of bank size
        ldx     #$01            ; High byte of bank size ($0100 = 256 bytes)
        jsr     _page_cache_set_bank_size

        ; Initialize cache with 2 banks for testing
        lda     #$02
        jsr     _page_cache_init
        rts
.endproc

; Enhanced bank emulation functions
.proc _change_bank
        ; A contains bank_id
        ; For emulation, we store bank_id + 1 (so bank 0 becomes 1, bank 1 becomes 2, etc.)
        clc
        adc     #1
        sta     current_bank
        rts
.endproc

.proc _set_default_bank
        ; Default bank is represented as 0 in our emulation
        lda     #0
        sta     current_bank
        rts
.endproc

.proc _get_bank_base
        ; Calculate bank base address: mock_bank_data + (current_bank * bank_size)
        ; Since bank_size = $100 (256), we can use current_bank as high byte offset
        lda     current_bank
        beq     default_bank    ; If current_bank = 0, use base address

        ; Calculate: mock_bank_data + (current_bank * 256)
        ; current_bank * 256 means current_bank becomes the high byte offset
        ldx     #>mock_bank_data    ; High byte base  
        txa                         ; Get high byte in A
        clc
        adc     current_bank        ; Add current_bank to high byte
        tax                         ; Put result back in X (high byte)
        lda     #<mock_bank_data    ; Low byte unchanged
        rts

default_bank:
        ; Return base mock_bank_data address
        lda     #<mock_bank_data
        ldx     #>mock_bank_data
        rts
.endproc

_main:
        ; Initialize test data
        jsr     init_test_data

t1:     ; Test 1: Insert into empty cache
        ; Set up insert parameters for first entry
        lda     #$12
        sta     _insert_params+page_cache_insert_params::path_hash
        lda     #$34
        sta     _insert_params+page_cache_insert_params::path_hash+1
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_id
        lda     #$12           ; 18 bytes total (16 data + 2 header)
        sta     _insert_params+page_cache_insert_params::group_size
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_size+1
        mwa     #test_data_1, _insert_params+page_cache_insert_params::data_ptr
        lda     #$00
        sta     _insert_params+page_cache_insert_params::pg_flags
        lda     #$01
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        jsr     _page_cache_insert
t1_end:

t2:     ; Test 2: Insert entry that should go in middle (hash 2000 < 5678)
        ; This will test entry shifting logic
        lda     #$20
        sta     _insert_params+page_cache_insert_params::path_hash
        lda     #$00
        sta     _insert_params+page_cache_insert_params::path_hash+1
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_id
        lda     #$1A           ; 26 bytes total (24 data + 2 header)
        sta     _insert_params+page_cache_insert_params::group_size
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_size+1
        mwa     #test_data_2, _insert_params+page_cache_insert_params::data_ptr
        lda     #$00
        sta     _insert_params+page_cache_insert_params::pg_flags
        lda     #$02
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        jsr     _page_cache_insert
t2_end:

t3:     ; Test 3: Insert entry at end (hash 5678 > previous entries)
        ; This tests insertion without shifting
        lda     #$56
        sta     _insert_params+page_cache_insert_params::path_hash
        lda     #$78
        sta     _insert_params+page_cache_insert_params::path_hash+1
        lda     #$01
        sta     _insert_params+page_cache_insert_params::group_id
        lda     #$22           ; 34 bytes total (32 data + 2 header)
        sta     _insert_params+page_cache_insert_params::group_size
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_size+1
        mwa     #test_data_3, _insert_params+page_cache_insert_params::data_ptr
        lda     #$01
        sta     _insert_params+page_cache_insert_params::pg_flags
        lda     #$03
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        jsr     _page_cache_insert
t3_end:

t4:     ; Test 4: Try to insert duplicate entry (should fail)
        ; Use same hash/group_id as t1
        lda     #$12
        sta     _insert_params+page_cache_insert_params::path_hash
        lda     #$34
        sta     _insert_params+page_cache_insert_params::path_hash+1
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_id
        lda     #$12
        sta     _insert_params+page_cache_insert_params::group_size
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_size+1
        mwa     #test_data_1, _insert_params+page_cache_insert_params::data_ptr
        lda     #$00
        sta     _insert_params+page_cache_insert_params::pg_flags
        lda     #$01
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        jsr     _page_cache_insert
t4_end:

t5:     ; Test 5: Insert entry with different group_id for existing hash
        ; This should succeed (hash=1234, group_id=1 vs existing hash=1234, group_id=0)
        lda     #$12
        sta     _insert_params+page_cache_insert_params::path_hash
        lda     #$34
        sta     _insert_params+page_cache_insert_params::path_hash+1
        lda     #$01           ; Different group_id
        sta     _insert_params+page_cache_insert_params::group_id
        lda     #$1A
        sta     _insert_params+page_cache_insert_params::group_size
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_size+1
        mwa     #test_data_2, _insert_params+page_cache_insert_params::data_ptr
        lda     #$00
        sta     _insert_params+page_cache_insert_params::pg_flags
        lda     #$02
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        jsr     _page_cache_insert
t5_end:

t6:     ; Test 6: Insert another entry to test sorting
        ; Insert hash 3000 which should go between 2000 and 1234
        lda     #$30
        sta     _insert_params+page_cache_insert_params::path_hash
        lda     #$00
        sta     _insert_params+page_cache_insert_params::path_hash+1
        lda     #$02
        sta     _insert_params+page_cache_insert_params::group_id
        lda     #$22
        sta     _insert_params+page_cache_insert_params::group_size
        lda     #$00
        sta     _insert_params+page_cache_insert_params::group_size+1
        mwa     #test_data_3, _insert_params+page_cache_insert_params::data_ptr
        lda     #$01
        sta     _insert_params+page_cache_insert_params::pg_flags
        lda     #$03
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        jsr     _page_cache_insert
t6_end:

        rts 