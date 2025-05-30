.export     _page_cache_find_position

.import     _cache
.import     _find_params
.import     calc_entry_loc
.import     entry_loc

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; page_cache_find_position
;
; find and set the 'position' value in parameters block for the index
; location for a particular path_hash and group_id.
; sets 'found_exact' to 1 if we hit an exact match (e.g. to find entry
; in the cache), or 0 if this pair of values wasn't in the cache index
; yet (e.g. to allow inserting)
; --------------------------------------------------------------------
.proc _page_cache_find_position
        ; Initialize variables
        lda     #0                  ; found_exact = 0
        sta     _find_params+page_cache_find_params::found_exact
        sta     _find_params+page_cache_find_params::entry_loc
        sta     _find_params+page_cache_find_params::entry_loc+1

        ldx     _cache+page_cache::entry_count
        bne     not_empty

        ; Handle empty cache case, e.g. inserting first cache entry
        stx     _find_params+page_cache_find_params::position  ; position = 0
        rts

not_empty:
        dex                     ; right = entry_count - 1
        stx     tmp2            ; store in right
        ldx     #0
        stx     tmp1            ; left = 0

binary_search:
        ; Check if left > right
        lda     tmp1
        cmp     tmp2
        bcc     calc_mid           ; if left < right, continue
        beq     calc_mid           ; if left = right, do one more iteration

search_done:
        ; if left > right, we're done
        ; Search complete without exact match
        sta     _find_params+page_cache_find_params::position  ; position = left
        rts

calc_mid:
        ; Calculate mid = (left + right) >> 1, using carry for high bit
        lda     tmp1
        clc
        adc     tmp2
        ror     a               ; divide by 2, carry into bit 7
        sta     tmp3            ; store in mid
        ; we can pre-emptively set position to this mid, as other conditions change it if it isn't, and this saves it while it's still in A
        sta     _find_params+page_cache_find_params::position

        ; use calc_entry_loc to find the entry location for value in A (mid)
        jsr     calc_entry_loc

        ; also store it into find params, so when we exit we have the correct location there already
        lda     entry_loc
        sta     ptr1
        sta     _find_params+page_cache_find_params::entry_loc
        lda     entry_loc+1
        sta     ptr1+1
        sta     _find_params+page_cache_find_params::entry_loc+1

        ; Compare first hash byte
        ldy     #page_cache_entry::path_hash
        lda     (ptr1),y
        cmp     _find_params+page_cache_find_params::path_hash
        bne     key_differs

        ; First byte matches, compare second byte
        iny
        lda     (ptr1),y
        cmp     _find_params+page_cache_find_params::path_hash+1
        bne     key_differs

        ; Hash matches, compare group_id. This relies on group_id being next byte in struct
        iny
        lda     (ptr1),y                ; group_id
        cmp     _find_params+page_cache_find_params::group_id
        bne     key_differs

        ; Exact match found!
        inc     _find_params+page_cache_find_params::found_exact  ; set found_exact = 1

        ; set position to mid
        ; mva     tmp3, _find_params+page_cache_find_params::position
        ; position was pre-emptively set already
        rts

adjust_right_norm:
        ; A = mid
        sec
        sbc     #1                      ; mid - 1
        sta     tmp2                    ; right = mid - 1
        bcs     binary_search           ; always, as mid will never overflow

adjust_left_norm:
        ; A = mid
        clc
        adc     #1                      ; mid + 1
        sta     tmp1                    ; left = mid + 1
        bcc     binary_search           ; always, as mid will never overflow

key_differs:
        ; we can pre-load tmp3 (mid) into A as it's used in all cases following and doesn't affect carry
        lda     tmp3
        bcc     adjust_left

adjust_right:
        ; Entry > Search, adjust right
        ; Check if left == mid
        cmp     tmp1
        bne     adjust_right_norm
        ; left == mid case

set_pos_return:
        sta     _find_params+page_cache_find_params::position  ; position = mid
        rts

adjust_left:
        ; Check if right == mid
        cmp     tmp2
        bne     adjust_left_norm

        ; right == mid case
        clc
        adc     #1                 ; mid + 1
        bcc     set_pos_return

.endproc 