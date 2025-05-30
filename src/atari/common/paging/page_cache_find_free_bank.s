.export     _page_cache_find_free_bank

.import     _cache
.import     _find_bank_params
.import     try_free_space

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; page_cache_find_free_bank
; Uses:
;   ptr1 = entry pointer for scanning
;   ptr2 = best_space (2 bytes)
;   tmp1 = best_bank (1 byte)
;   tmp2 = bank_index (1 byte)
;   tmp3/tmp4 = current bank space (2 bytes)
; --------------------------------------------------------------------

; TODO: error handling if init not setup, or there are no banks available.

.proc _page_cache_find_free_bank
        lda     _cache+page_cache::max_banks
        bne     :+

        ; exit if there are no banks at all
        jmp     too_large

:
        ; First check if size is larger than bank can hold
        lda     _find_bank_params+page_cache_find_bank_params::size_needed+1  ; High byte
        cmp     #>BANK_SIZE
        bcc     size_ok        ; If high byte less, definitely ok
        bne     failed_size    ; If high byte greater, fail
        lda     _find_bank_params+page_cache_find_bank_params::size_needed    ; Low byte
        cmp     #<BANK_SIZE
        bcc     size_ok        ; If low byte < BANK_SIZE low byte, ok

failed_size:
        jmp     too_large     ; Too far for direct branch

size_ok:

try_alloc:
        ; Initialize best bank and space
        lda     #$FF
        sta     tmp1            ; best_bank = 0xFF (not found)
        lda     #0
        sta     ptr2           ; best_space low = 0
        sta     ptr2+1         ; best_space high = 0
        sta     tmp2           ; bank_index = 0

bank_loop:
        ; Get index into bank_free_space array (bank_index * 2)
        lda     tmp2           ; bank_index
        asl                ; * 2 for word offset
        tay

        ; Load bank space into tmp3/tmp4
        lda     _cache+page_cache::bank_free_space,y
        sta     tmp3           ; Low byte
        iny
        lda     _cache+page_cache::bank_free_space,y
        sta     tmp4           ; High byte

        ; Skip if bank doesn't have enough space
        cmp     _find_bank_params+page_cache_find_bank_params::size_needed+1
        bcc     next_bank      ; If high byte less, skip
        bne     check_entries  ; If high byte greater, check entries
        lda     tmp3           ; High bytes equal, compare low
        cmp     _find_bank_params+page_cache_find_bank_params::size_needed
        bcc     next_bank      ; If low byte less, skip

check_entries:
        ; Initialize entry pointer
        lda     #<(_cache+page_cache::entries)
        sta     ptr1
        lda     #>(_cache+page_cache::entries)
        sta     ptr1+1

        ldx     #0              ; entry counter
scan_loop:
        cpx     _cache+page_cache::entry_count
        beq     update_best     ; No matches, update best if better space

        ; Check if entry is in this bank
        ldy     #page_cache_entry::bank_id
        lda     (ptr1),y
        cmp     tmp2           ; Compare with current bank_index
        bne     next_entry

        ; Check path hash
        ldy     #page_cache_entry::path_hash
        lda     (ptr1),y        ; Load first byte of hash
        cmp     _find_bank_params+page_cache_find_bank_params::path_hash
        bne     next_entry
        iny
        lda     (ptr1),y        ; Load second byte of hash
        cmp     _find_bank_params+page_cache_find_bank_params::path_hash+1
        bne     next_entry

        ; Found matching bank with enough space - use it!
        lda     tmp2           ; Get bank_index
        sta     _find_bank_params+page_cache_find_bank_params::bank_id
        rts

next_entry:
        ; Move to next entry
        lda     ptr1
        clc
        adc     #PAGE_CACHE_ENTRY_SIZE
        sta     ptr1
        bcc     :+
        inc     ptr1+1
:       inx
        bne     scan_loop

update_best:
        ; Compare with current best space
        lda     tmp4           ; High byte
        cmp     ptr2+1         ; Compare with best space high
        bcc     next_bank      ; If less than best, try next
        bne     set_best       ; If greater than best, update
        lda     tmp3           ; High bytes equal, compare low
        cmp     ptr2
        bcc     next_bank      ; If less than best, try next
        beq     next_bank      ; If equal, keep current

set_best:
        ; Update best values
        lda     tmp3
        sta     ptr2           ; best_space low
        lda     tmp4
        sta     ptr2+1         ; best_space high
        lda     tmp2           ; bank_index
        sta     tmp1           ; best_bank

next_bank:
        ; Move to next bank
        inc     tmp2           ; bank_index++
        lda     tmp2
        cmp     _cache+page_cache::max_banks
        bne     bank_loop

        ; Check if we found a bank with enough space
        lda     tmp1
        cmp     #$FF
        beq     need_space      ; If no bank found, try freeing space

        ; Store best bank in result and return
        sta     _find_bank_params+page_cache_find_bank_params::bank_id
        rts

need_space:
        ; Try to free up space
        jsr     try_free_space
        beq     too_large

        jmp     try_alloc      ; If space was freed, try allocation again

too_large:
no_space:
        ; Return 0xFF to indicate no space found
        lda     #$FF
        sta     _find_bank_params+page_cache_find_bank_params::bank_id
        rts

.endproc 