.export     _page_cache_remove_group

.import     _cache
.import     _change_bank
.import     _find_params
.import     _get_bank_base
.import     _memmove
.import     _page_cache_find_position
.import     _remove_group_params
.import     _set_default_bank
.import     adjust_size
.import     bank_id
.import     calc_entry_loc
.import     end_offset
.import     entry_loc
.import     entry_offset
.import     group_size
.import     highest_offset
.import     move_size
.import     mul8
.import     pushax

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; page_cache_remove_group
; --------------------------------------------------------------------

.proc _page_cache_remove_group
        ; Set up find_params from remove_group_params
        lda     _remove_group_params+page_cache_remove_group_params::path_hash
        sta     _find_params+page_cache_find_params::path_hash
        lda     _remove_group_params+page_cache_remove_group_params::path_hash+1
        sta     _find_params+page_cache_find_params::path_hash+1
        lda     _remove_group_params+page_cache_remove_group_params::group_id
        sta     _find_params+page_cache_find_params::group_id

        ; Find the entry
        jsr     _page_cache_find_position

        ; Check if entry exists
        lda     _find_params+page_cache_find_params::found_exact
        bne     found
        jmp     not_found

found:
        ; Calculate entry location
        lda     _find_params+page_cache_find_params::found_exact
        jsr     calc_entry_loc        ; Will put entry address in entry_loc

        ; Copy entry_loc to ptr1 for indirect addressing
        lda     entry_loc
        sta     ptr1
        lda     entry_loc+1
        sta     ptr1+1

        ; Get bank_id and calculate offset into bank_free_space
        ldy     #page_cache_entry::bank_id
        lda     (ptr1),y
        sta     bank_id             ; store it for later
        asl     a                   ; * 2 for word offset - safe as banks max is 64
        tax                     ; Save in X for indexing bank_free_space

        ; Save the group size we'll use for all adjustments
        ldy     #page_cache_entry::group_size
        lda     (ptr1),y
        sta     adjust_size
        iny
        lda     (ptr1),y
        sta     adjust_size+1

        ; Update bank free space - add group_size to bank_free_space[bank_id]
        lda     _cache+page_cache::bank_free_space,x
        clc
        adc     adjust_size        ; Use saved size
        sta     _cache+page_cache::bank_free_space,x
        inx
        lda     _cache+page_cache::bank_free_space,x
        adc     adjust_size+1      ; Use saved size
        sta     _cache+page_cache::bank_free_space,x

        ; Save our entry's bank_offset in tmp1/2
        ; and initialize highest_offset to our offset
        ldy     #page_cache_entry::bank_offset
        lda     (ptr1),y
        sta     tmp1
        sta     highest_offset
        iny
        lda     (ptr1),y
        sta     tmp2
        sta     highest_offset+1

        ; Start scanning from beginning of entries
        lda     #<(_cache+page_cache::entries)
        sta     ptr1
        lda     #>(_cache+page_cache::entries)
        sta     ptr1+1

        ldx     #0                  ; Entry counter
scan_loop:
        cpx     _cache+page_cache::entry_count
        bne     continue_scan
        jmp     scan_done

continue_scan:
        ; Check if this is our entry
        cpx     _find_params+page_cache_find_params::position
        beq     next_entry

        ; Check if same bank
        ldy     #page_cache_entry::bank_id
        lda     (ptr1),y           ; Get bank_id
        cmp     bank_id
        bne     next_entry

        ; Get this entry's offset
        iny                    ; Point to bank_offset
        lda     (ptr1),y
        sta     entry_offset
        iny
        lda     (ptr1),y
        sta     entry_offset+1

        ; save the entry's group size
        iny                    ; Point to group_size
        lda     (ptr1),y
        sta     group_size
        iny
        lda     (ptr1),y
        sta     group_size+1

        ; Compare with our offset (entry_offset > tmp1/2?)
        lda     entry_offset+1     ; Compare high bytes first
        cmp     tmp2
        bcc     next_entry        ; If high byte less, definitely not greater
        bne     calc_end_offset   ; If high byte greater, definitely greater
        lda     entry_offset      ; High bytes equal, compare low bytes
        cmp     tmp1
        bcc     next_entry        ; If low byte less or equal, not greater
        beq     next_entry        ; Equal case

calc_end_offset:
        ; Add group_size to get end offset for highest_offset calculation
        clc
        lda     entry_offset
        adc     group_size        ; Add low byte of group_size
        sta     end_offset
        lda     entry_offset+1
        adc     group_size+1      ; Add high byte of group_size
        sta     end_offset+1

        ; Update highest_offset if this is higher (entry_offset > highest_offset?)
        ; lda     end_offset+1     ; Compare high bytes first
        cmp     highest_offset+1
        bcc     adjust_offset        ; If high byte less, definitely not greater
        bne     update_highest    ; If high byte greater, definitely greater
        lda     end_offset      ; High bytes equal, compare low bytes
        cmp     highest_offset
        bcc     adjust_offset        ; If low byte less or equal, not greater
        beq     adjust_offset        ; Equal case


update_highest:
        ; lda     end_offset - A is already end_offset
        sta     highest_offset
        lda     end_offset+1
        sta     highest_offset+1

adjust_offset:
        ; Now adjust this entry's offset by subtracting the adjustment size
        sec
        lda     entry_offset
        sbc     adjust_size       ; Use saved adjustment size
        sta     entry_offset      ; Save adjusted value
        lda     entry_offset+1
        sbc     adjust_size+1     ; Use saved adjustment size
        sta     entry_offset+1

        ; Store adjusted offset back to entry
        ldy     #page_cache_entry::bank_offset+1
        ; lda     entry_offset
        sta     (ptr1),y
        dey
        lda     entry_offset
        sta     (ptr1),y

next_entry:
        ; Move to next entry
        lda     ptr1
        clc
        adc     #PAGE_CACHE_ENTRY_SIZE
        sta     ptr1
        bcc     :+
        inc     ptr1+1

        ; and increment our loop counter for all entries
:       inx
        jmp     scan_loop

scan_done:
        ; Restore our entry pointer - why?
        lda     entry_loc
        sta     ptr1
        lda     entry_loc+1
        sta     ptr1+1

        ; Calculate total size to move
        sec
        lda     highest_offset
        sbc     tmp1              ; Subtract our offset
        sta     move_size
        lda     highest_offset+1
        sbc     tmp2
        sta     move_size+1

        ; If nothing to move, we're done with bank operations
        ora     move_size
        bne     move_bank
        jmp     bank_done

move_bank:
        ; Switch to correct bank
        lda     bank_id
        jsr     _change_bank

        ; Get bank base address into ptr3/ptr4 for calculations
        jsr     _get_bank_base
        sta     ptr3
        stx     ptr3+1

        ; Calculate source address (bank_base + offset + group_size)
        ; First add offset
        clc
        ; lda     ptr3 - already in A
        adc     tmp1              ; Add low byte of offset
        sta     ptr2              ; Store in ptr2 for source
        lda     ptr3+1
        adc     tmp2              ; Add high byte of offset
        sta     ptr2+1

        ; Now add group_size to get final source
        clc
        lda     ptr2
        adc     group_size        ; Add low byte of group_size
        sta     ptr2              ; Store back in ptr2
        lda     ptr2+1
        adc     group_size+1      ; Add high byte of group_size
        sta     ptr2+1

        ; Calculate destination address (bank_base + offset)
        lda     ptr3
        clc
        adc     tmp1              ; Add low byte of offset
        tay                   ; Save low byte for pushax
        lda     ptr3+1
        adc     tmp2              ; Add high byte of offset
        tax                     ; high byte for pushax
        tya                     ; low byte for pushax
        jsr     pushax

        ; Push source address
        lda     ptr2              ; Load source address
        ldx     ptr2+1
        jsr     pushax

        ; Push size
        lda     move_size         ; Load size to move
        ldx     move_size+1
        jsr     _memmove

        ; reset to normal memory to access cache again
        jsr     _set_default_bank

bank_done:
        ; Now continue with removing entry from index
        ; Remove entry from index by moving following entries up
        lda     _cache+page_cache::entry_count
        sec
        sbc     _find_params+page_cache_find_params::position     ; A = count - position
        beq     last_entry                             ; If removing last entry, no move needed

        sec                     ; Set carry for sbc
        sbc     #1                  ; Subtract 1 since position is included
        jsr     mul8                                   ; Get number of bytes to move in tmp1/tmp2

        ; Set up memmove parameters
        lda     entry_loc                              ; Destination is current entry
        ldx     entry_loc+1
        jsr     pushax

        ; Source is next entry
        ; lda     entry_loc ; pushax doesn't change A or X
        clc
        adc     #PAGE_CACHE_ENTRY_SIZE
        tay
        lda     entry_loc+1
        adc     #0
        tax
        tya
        jsr     pushax

        ; Size is in tmp1/tmp2
        lda     tmp1
        ldx     tmp2
        jsr     _memmove

last_entry:
        ; Decrement entry count
        dec     _cache+page_cache::entry_count

        ; Set success = 1
        lda     #1
        bne     set_success        ; Always taken

not_found:
        lda     #0
set_success:
        sta     _remove_group_params+page_cache_remove_group_params::success
        rts

.endproc 