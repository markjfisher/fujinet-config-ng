.export _main
.export t1
.export t2
.export t3
.export t4
.export t5
.export t1_end
.export t2_end
.export t3_end
.export t4_end
.export t5_end
.export first_hash

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
first_hash:      .res 2          ; Storage for first hash value

.segment "CODE"

_main:

t1:     ; Test 1: Simple path with *.* filter
        lda     #<test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        lda     #>test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<test_filter1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>test_filter1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
        ; Store hash for later comparison
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        sta     first_hash
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path_hash+1
        sta     first_hash+1
t1_end:

t2:     ; Test 2: Same path, different filter
        lda     #<test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        lda     #>test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<test_filter2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>test_filter2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
t2_end:

t3:     ; Test 3: Different path, same filter
        lda     #<test_path2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        lda     #>test_path2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<test_filter2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>test_filter2
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
t3_end:

t4:     ; Test 4: Empty path (should produce default hash)
        lda     #$00
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<test_filter1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>test_filter1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
t4_end:

t5:     ; Test 5: Path with no filter
        lda     #<test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path
        lda     #>test_path1
        sta     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        lda     #<null_filter
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter
        lda     #>null_filter
        sta     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        jsr     _page_cache_set_path_filter
t5_end:
        rts 