.export     _page_cache_remove_path

.import     _cache
.import     _page_cache_remove_group
.import     _remove_group_params
.import     _remove_path_params
.import     entry_index

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; page_cache_remove_path
; --------------------------------------------------------------------
.proc _page_cache_remove_path
        ; Initialize removed count
        lda     #0
        sta     _remove_path_params+page_cache_remove_path_params::removed_count
        sta     entry_index      ; Initialize entry index to 0

        ; Initialize entry pointer to start of entries
        lda     #<(_cache+page_cache::entries)
        sta     ptr2
        lda     #>(_cache+page_cache::entries)
        sta     ptr2+1

scan_loop:
        ; Check if we've reached the end
        lda     entry_index
        cmp     _cache+page_cache::entry_count
        bcs     done

        ; Compare first hash byte
        ldy     #0
        lda     (ptr2),y
        cmp     _remove_path_params+page_cache_remove_path_params::path_hash  ; Compare with stored hash
        beq     check_second    ; Equal, check second byte
        bcc     next_entry     ; Less than target, keep scanning
        bcs     done           ; Greater than target, we're done

check_second:
        ; First byte matches, check second byte
        iny
        lda     (ptr2),y
        cmp     _remove_path_params+page_cache_remove_path_params::path_hash+1  ; Compare with stored hash
        beq     found_match     ; Equal, we found a match
        bcc     next_entry     ; Less than target, keep scanning
        bcs     done           ; Greater than target, we're done

found_match:
        ; Hash matches! Set up remove_group_params and call remove_group
        ; Get group_id from entry
        ldy     #page_cache_entry::group_id
        lda     (ptr2),y
        sta     _remove_group_params+page_cache_remove_group_params::group_id

        ; Copy path hash to remove_group_params
        lda     _remove_path_params+page_cache_remove_path_params::path_hash
        sta     _remove_group_params+page_cache_remove_group_params::path_hash
        lda     _remove_path_params+page_cache_remove_path_params::path_hash+1
        sta     _remove_group_params+page_cache_remove_group_params::path_hash+1

        ; Call remove_group
        jsr     _page_cache_remove_group

        ; Check if removal was successful
        lda     _remove_group_params+page_cache_remove_group_params::success
        beq     next_entry

        ; Removal succeeded, increment removed count
        inc     _remove_path_params+page_cache_remove_path_params::removed_count

        ; Don't increment entry_index since entries shifted down
        bne     scan_loop

next_entry:
        ; Move to next entry - add index size to ptr2
        lda     ptr2
        clc
        adc     #PAGE_CACHE_ENTRY_SIZE
        sta     ptr2
        bcc     :+
        inc     ptr2+1
:
        ; Move to next entry index
        inc     entry_index
        bne     scan_loop

done:
        rts

.endproc 