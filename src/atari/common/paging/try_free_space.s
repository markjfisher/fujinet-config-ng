.export     try_free_space

.import     _cache
.import     _page_cache_expel_path
.import     _page_cache_remove_group
.import     _remove_group_params
.import     _remove_path_params
.import     attempts

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"
.include    "fc_strlcpy.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; try_free_space
; Attempts to free up space by:
; 1. Trying to expel paths up to 3 times
; 2. If that doesn't work, removing entries one by one
; Returns:
;   A = 1 if space was freed, 0 if not
; --------------------------------------------------------------------
.proc try_free_space
        lda     #0
        sta     attempts       ; Reset attempts counter

try_expel:
        ; Check if we've tried expelling too many times
        lda     attempts
        cmp     #3
        bcs     try_remove_entries  ; If attempts >= 3, try removing entries

        ; Increment attempts counter
        inc     attempts

        ; Try to expel a path
        jsr     _page_cache_expel_path

        ; Check if any entries were removed
        lda     _remove_path_params+page_cache_remove_path_params::removed_count
        bne     success       ; If entries removed, return success

try_remove_entries:
        ; Get first entry's hash and group_id
        lda     _cache+page_cache::entries+page_cache_entry::path_hash
        sta     _remove_group_params+page_cache_remove_group_params::path_hash
        lda     _cache+page_cache::entries+page_cache_entry::path_hash+1
        sta     _remove_group_params+page_cache_remove_group_params::path_hash+1
        lda     _cache+page_cache::entries+page_cache_entry::group_id
        sta     _remove_group_params+page_cache_remove_group_params::group_id

        ; Remove the entry
        jsr     _page_cache_remove_group

        ; Entry was removed, return success
success:
        lda     #1
        rts

failed:
        lda     #0
        rts

.endproc 