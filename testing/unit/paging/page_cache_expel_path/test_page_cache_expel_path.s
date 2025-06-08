.export _main
.export t1
.export t2
.export t3
.export t1_end
.export t2_end
.export t3_end
.export _page_cache_remove_path

.import _page_cache_expel_path
.import _cache
.import _remove_path_params
.import _find_bank_params
.import remove_path_called
.import remove_path_hash_low
.import remove_path_hash_high

.include "zp.inc"
.include "macros.inc"
.include "page_cache.inc"

.segment "CODE"

; Reset mock tracking variables
.proc reset_mock_state
        lda     #0
        sta     remove_path_called
        sta     remove_path_hash_low
        sta     remove_path_hash_high
        rts
.endproc

; Mock for page_cache_remove_path - captures parameters it was called with
.proc _page_cache_remove_path
        ; Set flag that we were called
        lda     #1
        sta     remove_path_called

        ; Capture hash values that were passed in
        lda     _remove_path_params+page_cache_remove_path_params::path_hash
        sta     remove_path_hash_low
        lda     _remove_path_params+page_cache_remove_path_params::path_hash+1
        sta     remove_path_hash_high
        rts
.endproc

_main:

t1:     ; Test 1: Empty cache (entry_count = 0)
        ; Should not call remove_path at all
        jsr     reset_mock_state

        ; Set entry_count to 0
        lda     #0
        sta     _cache+page_cache::entry_count

        ; Set up path hash to expel (should not matter as cache is empty)
        lda     #$12
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$34
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1

        jsr     _page_cache_expel_path
t1_end:

t2:     ; Test 2: Cache with entries but none match path hash
        ; Should call remove_path with first entry's hash ($1234)
        jsr     reset_mock_state

        ; Set entry_count back to 2
        lda     #2
        sta     _cache+page_cache::entry_count

        ; Set up path hash to expel (different from both entries)
        lda     #$9A
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$BC
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1

        jsr     _page_cache_expel_path
t2_end:

t3:     ; Test 3: Cache with matching entry
        ; Should call remove_path with second entry's hash ($5678)
        jsr     reset_mock_state

        ; Entry count is already 2
        ; Set up path hash to expel (matches first entry)
        lda     #$12
        sta     _find_bank_params+page_cache_find_bank_params::path_hash
        lda     #$34
        sta     _find_bank_params+page_cache_find_bank_params::path_hash+1

        jsr     _page_cache_expel_path
t3_end:

        rts 