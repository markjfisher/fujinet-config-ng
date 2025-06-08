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
.export _fuji_read_directory_block
.export copy_1234
.export copy_9abc

.import test_buffer
.import _page_cache_get_pagegroup
.import _page_cache_init
.import _page_cache_insert
.import _page_cache_find_position
.import _page_cache_find_free_bank
.import _memcpy
.import _memmove
.import _cache
.import _get_pagegroup_params
.import _set_path_flt_params
.import _insert_params
.import _find_params
.import _find_bank_params
.import entry_loc
.import page_cache_buf
.import mock_bank_data
.import mock_fn_block
.import mock_fn_block_9abc
.import current_bank
.import invalid_fn_data

.include "zp.inc"
.include "macros.inc"
.include "page_cache.inc"

.segment "CODE"

; Initialize test data
.proc init_test_data
        ; Initialize empty cache with one bank
        lda     #$01            ; Just one bank for our test area
        jsr     _page_cache_init
        rts
.endproc

; Mock bank switching functions
.proc _change_bank
        ; A contains bank_id
        sta     current_bank
        rts
.endproc

.proc _set_default_bank
        lda     #$FF
        sta     current_bank
        rts
.endproc

.proc _get_bank_base
        ; For our test, we just return the base of our mock bank data
        ; without modifying any other registers
        lda     #<mock_bank_data
        ldx     #>mock_bank_data
        rts
.endproc

; Mock fujinet read function
_fuji_read_directory_block:
        ; Check if we're searching for $9ABC
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        cmp     #$9A
        bne     check_1234
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1
        cmp     #$BC
        bne     check_1234

        ; Use mock_fn_block_9abc for $9ABC search
        ldx     #0
copy_9abc:
        lda     mock_fn_block_9abc,x    ; Copy complete response including header
        sta     page_cache_buf,x
        inx
        cpx     #$5E            ; Size of our mock data (94 bytes)
        bne     copy_9abc
        jmp     done

check_1234:
        ; Check if we're searching for $1234
        cmp     #$12
        bne     use_invalid
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1
        cmp     #$34
        bne     use_invalid

        ; Use mock_fn_block for $1234 search
        ldx     #0
copy_1234:
        lda     mock_fn_block,x         ; Copy complete response including header
        sta     page_cache_buf,x
        inx
        cpx     #$5E            ; Size of our mock data (94 bytes)
        bne     copy_1234
        jmp     done

use_invalid:
        ; Use invalid data for any other hash
        ldx     #0
copy_invalid:
        lda     invalid_fn_data,x
        sta     page_cache_buf,x
        inx
        cpx     #4              ; Just copy the invalid header
        bne     copy_invalid

done:   lda     #1              ; Return success
        rts


_main:
        ; Initialize test data
        jsr     init_test_data

t1:     ; Test 1: Error on non-page-aligned position
        ; Set up non-aligned position
        lda     #25
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        lda     #0
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position+1
        lda     #16
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::page_size

        ; Set data pointer
        mwa     #test_buffer, _get_pagegroup_params+page_cache_get_pagegroup_params::data_ptr

        jsr     _page_cache_get_pagegroup
t1_end:

t2:     ; Test 2: Get existing pagegroup from cache
        ; Set up aligned position for group 0
        lda     #0
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position+1
        lda     #16
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::page_size

        ; Set path hash to match first cache entry
        lda     #$12
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        lda     #$34
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1

        ; Set data pointer
        mwa     #test_buffer, _get_pagegroup_params+page_cache_get_pagegroup_params::data_ptr

        jsr     _page_cache_get_pagegroup
t2_end:

t3:     ; Test 3: Get pagegroup from fujinet
        ; Set up aligned position for group 0
        lda     #0
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        lda     #0
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position+1
        lda     #16
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::page_size

        ; Set path hash to non-existent entry
        lda     #$9A
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        lda     #$BC
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1

        ; Set data pointer
        mwa     #test_buffer, _get_pagegroup_params+page_cache_get_pagegroup_params::data_ptr

        jsr     _page_cache_get_pagegroup
t3_end:

t4:     ; Test 4: Get second pagegroup from fujinet for 9ABC
        ; Set up aligned position for group 1 (16/16 = 2)
        lda     #16
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        lda     #0
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position+1
        lda     #16
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::page_size

        ; Set path hash to same 9ABC entry
        lda     #$9A
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        lda     #$BC
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1

        ; Set data pointer
        mwa     #test_buffer, _get_pagegroup_params+page_cache_get_pagegroup_params::data_ptr

        jsr     _page_cache_get_pagegroup
t4_end:

t5:     ; Test 5: Error on invalid fujinet data
        ; Set up aligned position for group 0
        lda     #0
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        lda     #0
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position+1
        lda     #16
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::page_size

        ; Set path hash to non-existent entry
        lda     #$CD
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        lda     #$EF
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1

        ; Set data pointer
        mwa     #test_buffer, _get_pagegroup_params+page_cache_get_pagegroup_params::data_ptr

        jsr     _page_cache_get_pagegroup
t5_end:

t6:     ; Test 6: Error when fujinet returns groups that don't include requested group_id
        ; Request group_id 5 (80/16 = 5), but fujinet will return groups 0,1 for hash 1234
        ; This tests the defensive validation logic to prevent infinite loops
        lda     #80
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        lda     #0
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position+1
        lda     #16
        sta     _get_pagegroup_params+page_cache_get_pagegroup_params::page_size

        ; Use hash 1234 which will return groups 0,1 (but we're requesting group 5)
        lda     #$12
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        lda     #$34
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1

        ; Set data pointer
        mwa     #test_buffer, _get_pagegroup_params+page_cache_get_pagegroup_params::data_ptr

        jsr     _page_cache_get_pagegroup
t6_end:

        rts 