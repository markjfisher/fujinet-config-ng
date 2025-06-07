.export     _page_cache_check_exists

.import     _div_i16_by_i8
.import     _find_params
.import     _get_pagegroup_params
.import     _page_cache_find_position
.import     _set_path_flt_params
.import     pusha
.import     return0
.import     return1

.include    "page_cache.inc"
.include    "macros.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; _page_cache_check_exists
; Checks if the given pagegroup exists in cache without retrieving it
; Uses same parameters as _page_cache_get_pagegroup in _get_pagegroup_params
; 
; Returns (enum-like values):
;   0 = EXISTS: pagegroup found in cache
;   1 = CACHE_MISS: valid input, not found in cache
;   2 = BOUNDARY_ERROR: dir_position not on page boundary
; --------------------------------------------------------------------
_page_cache_check_exists:
        ; Convert dir_position to group_id (same logic as get_pagegroup)
        lda     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        ora     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position+1
        beq     skip_calc

        pusha   _get_pagegroup_params+page_cache_get_pagegroup_params::page_size
        setax   _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        jsr     _div_i16_by_i8          ; quotient in A, remainder in X

        ; Check if we're on page boundary (remainder should be 0)
        cpx     #$00
        bne     boundary_error          ; Not on page boundary

        jmp     store_group_id

skip_calc:
        lda     #$00                    ; group_id = 0 for dir_pos = 0

store_group_id:
        sta     _find_params+page_cache_find_params::group_id

        ; Copy path_hash from set_path_flt_params (should be set by caller)
        setax   _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        axinto  _find_params+page_cache_find_params::path_hash

        ; Check if pagegroup exists in cache
        jsr     _page_cache_find_position
        lda     _find_params+page_cache_find_params::found_exact
        bne     found

not_found:
        jmp     return1                 ; Return 1 = cache miss

boundary_error:
        lda     #2                      ; Return 2 = invalid input
        rts

found:
        jmp     return0                 ; Return 0 = found 