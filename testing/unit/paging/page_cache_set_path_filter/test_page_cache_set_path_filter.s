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
.export hash1
.export hash2
.export hash3
.export hash4
.export hash5

.include "fc_strlcpy.inc"
.include "page_cache.inc"
.include "macros.inc"
.include "zp.inc"

.import _page_cache_set_path_filter
.import _set_path_flt_params
.import test_path1
.import test_path2
.import test_filter1
.import test_filter2
.import null_filter

.segment "BSS"
hash1:      .res 2          ; path1 + filter1
hash2:      .res 2          ; path1 + filter2  
hash3:      .res 2          ; path2 + filter2
hash4:      .res 2          ; path1 + null_filter
hash5:      .res 2          ; path1 + filter1 (repeat test)

.segment "CODE"

_main:

t1:     ; Test 1: path1 + filter1 
        lda     #<test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        lda     #>test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<test_filter1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>test_filter1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
        ; Store hash
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        sta     hash1
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1
        sta     hash1+1
t1_end:

t2:     ; Test 2: Same path, different filter (should be different hash)
        lda     #<test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        lda     #>test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<test_filter2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>test_filter2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
        ; Store hash
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        sta     hash2
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1
        sta     hash2+1
t2_end:

t3:     ; Test 3: Different path, same filter (should be different hash)
        lda     #<test_path2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        lda     #>test_path2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<test_filter2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>test_filter2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
        ; Store hash
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        sta     hash3
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1
        sta     hash3+1
t3_end:

t4:     ; Test 4: Path with null filter (should be different from filtered versions)
        lda     #<test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        lda     #>test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<null_filter
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>null_filter
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
        ; Store hash
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        sta     hash4
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1
        sta     hash4+1
t4_end:

t5:     ; Test 5: Repeat test 1 - should get same hash (consistency test)
        lda     #<test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        lda     #>test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<test_filter1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>test_filter1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
        ; Store hash
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        sta     hash5
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1
        sta     hash5+1
t5_end:

t6:     ; Test 6: Verify hash is not zero (should produce valid hash)
        ; Use the last computed hash from t5
        nop
t6_end:
        rts 