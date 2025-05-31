.export _main
.export t1
.export t2
.export t3
.export t4
.export t5
.export t6
.export t7
.export t1_end
.export t2_end
.export t3_end
.export t4_end
.export t5_end
.export t6_end
.export t7_end

.include "atari.inc"
.include "page_cache.inc"

.import _page_cache_find_free_bank
.import _find_bank_params
.import _cache
.import _set_mock_try_free_space

.segment "CODE"

_main:

t1:        ; Initialize mock to return 0 (no space freed)
        lda     #0
        jsr     _set_mock_try_free_space

        ; Test 1: Find bank for new hash with small size
        ; Should pick bank 0 as it has most free space
        lda     #$56
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$78
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1
        lda     #$00
        sta     _find_bank_params+page_cache_find_bank_params::size_needed
        lda     #$10            ; 4KB size
        sta     _find_bank_params+page_cache_find_bank_params::size_needed+1
        jsr     _page_cache_find_free_bank
t1_end:

t2:
        ; Test 2: Find bank for existing hash
        ; Should return bank 1 as it has matching hash
        lda     #$23
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$45
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1
        lda     #$00
        sta     _find_bank_params+page_cache_find_bank_params::size_needed
        lda     #$10            ; 4KB size
        sta     _find_bank_params+page_cache_find_bank_params::size_needed+1
        jsr     _page_cache_find_free_bank
t2_end:

t3:
        ; Test 3: Request too large for any bank
        ; Should return $FF (no bank) and try_free_space returns 0
        lda     #$99
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$99
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1
        lda     #$00
        sta     _find_bank_params+page_cache_find_bank_params::size_needed
        lda     #$50            ; 20KB size (> 16KB bank size)
        sta     _find_bank_params+page_cache_find_bank_params::size_needed+1
        jsr     _page_cache_find_free_bank
t3_end:

t4:
        ; Test 4: Find bank with exact size match
        ; Should pick bank 1 as it has 8KB free
        lda     #$AA
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$BB
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1
        lda     #$00
        sta     _find_bank_params+page_cache_find_bank_params::size_needed
        lda     #$20            ; 8KB size
        sta     _find_bank_params+page_cache_find_bank_params::size_needed+1
        jsr     _page_cache_find_free_bank
t4_end:

t5:
        ; Test 5: No space initially but try_free_space succeeds
        ; Should retry allocation after try_free_space returns non-zero
        lda     #1              ; Set mock to return success
        jsr     _set_mock_try_free_space
        lda     #$CC
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$DD
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1
        lda     #$00
        sta     _find_bank_params+page_cache_find_bank_params::size_needed
        lda     #$40            ; 16KB size (forces try_free_space call)
        sta     _find_bank_params+page_cache_find_bank_params::size_needed+1
        jsr     _page_cache_find_free_bank
t5_end:

t6:
        ; Test 6: Zero banks configured
        ; Should immediately return $FF
        lda     #0              ; Set max_banks to 0
        sta     _cache+page_cache::max_banks
        lda     #$EE
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$FF
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1
        lda     #$00
        sta     _find_bank_params+page_cache_find_bank_params::size_needed
        lda     #$10            ; 4KB size
        sta     _find_bank_params+page_cache_find_bank_params::size_needed+1
        jsr     _page_cache_find_free_bank
t6_end:

t7:
        ; Test 7: All banks full but request is small
        ; Should try_free_space and succeed
        lda     #3              ; Restore max_banks to 3
        sta     _cache+page_cache::max_banks
        lda     #$00            ; Set all banks to have only 256 bytes free
        sta     _cache+page_cache::bank_free_space
        sta     _cache+page_cache::bank_free_space+2
        sta     _cache+page_cache::bank_free_space+4
        lda     #$01
        sta     _cache+page_cache::bank_free_space+1
        sta     _cache+page_cache::bank_free_space+3
        sta     _cache+page_cache::bank_free_space+5
        lda     #1              ; Set mock to return success
        jsr     _set_mock_try_free_space
        lda     #$DD
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$EE
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1
        lda     #$00
        sta     _find_bank_params+page_cache_find_bank_params::size_needed
        lda     #$02            ; 512 bytes size (larger than available)
        sta     _find_bank_params+page_cache_find_bank_params::size_needed+1
        jsr     _page_cache_find_free_bank
t7_end:
        rts                     ; Final rts after all tests 