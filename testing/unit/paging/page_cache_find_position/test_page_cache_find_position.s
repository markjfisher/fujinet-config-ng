.export _main
.export t1
.export t1_end
.export t2
.export t2_end
.export t3
.export t3_end
.export t4
.export t4_end

.import _find_params
.import _cache
.import _page_cache_find_position

.include "zp.inc"
.include "macros.inc"
.include "page_cache.inc"

.code

_main:

; Test 1: Find exact match for first entry
t1:
        ; Setup find parameters for first entry (hash = 12,34)
        mva     #$12, _find_params+page_cache_find_params::path_hash
        mva     #$34, _find_params+page_cache_find_params::path_hash+1
        mva     #$00, _find_params+page_cache_find_params::group_id
        jsr     _page_cache_find_position
t1_end:

; Test 2: Find position for non-existent entry (hash = 13,00 between 12,34 and 23,45)
t2:
        ; Setup find parameters for non-existent entry
        mva     #$13, _find_params+page_cache_find_params::path_hash
        mva     #$00, _find_params+page_cache_find_params::path_hash+1
        mva     #$00, _find_params+page_cache_find_params::group_id
        jsr     _page_cache_find_position
t2_end:

; Test 3: Find exact match for last entry
t3:
        ; Setup find parameters for last entry (hash = 34,56)
        mva     #$34, _find_params+page_cache_find_params::path_hash
        mva     #$56, _find_params+page_cache_find_params::path_hash+1
        mva     #$00, _find_params+page_cache_find_params::group_id
        jsr     _page_cache_find_position
t3_end:

; Test 4: Find position for entry that would go at end
t4:
        ; Setup find parameters for beyond last entry (hash = 35,00)
        mva     #$35, _find_params+page_cache_find_params::path_hash
        mva     #$00, _find_params+page_cache_find_params::path_hash+1
        mva     #$00, _find_params+page_cache_find_params::group_id
        jsr     _page_cache_find_position
t4_end:
        rts
