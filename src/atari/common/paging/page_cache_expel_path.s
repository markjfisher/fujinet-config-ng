.export     _page_cache_expel_path

.import     _cache
.import     _find_bank_params
.import     _page_cache_remove_path
.import     _remove_path_params

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; page_cache_expel_path
; Uses:
;   ptr1 = pointer to current entry
; --------------------------------------------------------------------
.proc _page_cache_expel_path
        ; Initialize removed count to 0
        lda     #0
        sta     _remove_path_params+page_cache_remove_path_params::removed_count

        ; Exit early if no entries
        lda     _cache+page_cache::entry_count
        beq     done

        ; Initialize entry pointer to start of entries
        lda     #<(_cache+page_cache::entries)
        sta     ptr1
        lda     #>(_cache+page_cache::entries)
        sta     ptr1+1

        ldx     #0              ; Entry counter
scan_loop:
        cpx     _cache+page_cache::entry_count
        beq     done           ; Reached end of entries

        ; Check if this entry has a different path hash
        ; First byte
        ldy     #page_cache_entry::path_hash
        lda     (ptr1),y
        cmp     _find_bank_params+page_cache_find_bank_params::path_hash
        bne     found_different

        ; Second byte
        iny
        lda     (ptr1),y
        cmp     _find_bank_params+page_cache_find_bank_params::path_hash+1
        bne     found_different

next_entry:
        ; Move to next entry
        lda     ptr1
        clc
        adc     #PAGE_CACHE_ENTRY_SIZE
        sta     ptr1
        bcc     :+
        inc     ptr1+1
:       inx
        bne     scan_loop      ; Always taken as entry_count < 256

done:
        rts

found_different:
        ; Found entry with different hash, set up remove_path_params
        ldy     #page_cache_entry::path_hash
        lda     (ptr1),y        ; Get first byte of hash
        sta     _remove_path_params+page_cache_remove_path_params::path_hash
        iny
        lda     (ptr1),y        ; Get second byte of hash
        sta     _remove_path_params+page_cache_remove_path_params::path_hash+1

        ; Call page_cache_remove_path
        jmp     _page_cache_remove_path  ; Tail call optimization

.endproc 