        .export _page_cache_find_position
        .export _page_cache_find_free_bank
        .export _page_cache_insert
        .export _page_cache_remove_group
        .export _page_cache_remove_path
        .export _page_cache_init

        .import _cache
        .import _find_bank_params
        .import _find_params
        .import _insert_params
        .import _remove_group_params
        .import _remove_path_params

        .import _bank_count
        .import _change_bank
        .import _set_default_bank

        .import _memmove
        .import pushax

        .include "zeropage.inc"
        .include "page_cache_asm.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; page_cache_init(uint8_t max)
; Initialize the cache structure with the specified maximum number of banks
; Parameter is passed in A register
; --------------------------------------------------------------------
.proc _page_cache_init
        ; Store max_banks parameter
        sta _cache+page_cache::max_banks

        ; Calculate max_banks * 2 for array size (safe as max_banks <= 64)
        asl                 ; Double the value
        sta tmp1           ; Store for comparison

        ; Initialize entry_count to 0
        lda #0
        sta _cache+page_cache::entry_count

        ; Initialize bank_free_space array - each bank starts with BANK_SIZE free space
        ldx #0              ; Array index
init_banks:
        lda #<BANK_SIZE
        sta _cache+page_cache::bank_free_space,x
        inx
        lda #>BANK_SIZE
        sta _cache+page_cache::bank_free_space,x
        inx
        cpx tmp1           ; Compare with max_banks * 2
        bne init_banks

        rts
.endproc

; --------------------------------------------------------------------
; page_cache_find
; --------------------------------------------------------------------
.proc _page_cache_find_position
        ; Initialize variables
        lda #0                  ; found_exact = 0
        sta _find_params+page_cache_find_params::found_exact

        ; use x so we can decrement it easily
        ldx _cache+page_cache::entry_count  ; load cache.entry_count
        bne not_empty

        ; Handle empty cache case, e.g. inserting first cache entry
        stx _find_params+page_cache_find_params::position  ; position = 0
        rts

not_empty:
        dex                     ; right = entry_count - 1
        stx tmp2               ; store in right
        ldx #0
        stx tmp1               ; left = 0

binary_search:
        ; Check if left > right
        lda tmp1
        cmp tmp2
        bcc calc_mid           ; if left < right, continue
        beq calc_mid           ; if left = right, do one more iteration

search_done:
        ; if left > right, we're done
        ; Search complete without exact match
        sta _find_params+page_cache_find_params::position  ; position = left
        rts

calc_mid:
        ; Calculate mid = (left + right) >> 1
        lda tmp1               ; load left
        clc
        adc tmp2               ; add right
        lsr                    ; divide by 2
        sta tmp3               ; store in mid

        ; Calculate entry pointer: cache.entries + (mid * 8)
        asl                    ; mid * 2
        asl                    ; mid * 4
        asl                    ; mid * 8, as cache entry is 8 bytes
        
        ; Set up pointer to current entry
        clc
        adc #<(_cache+page_cache::entries)  ; Add low byte of cache.entries address
        sta ptr1
        lda #>(_cache+page_cache::entries)
        adc #0                 ; Add high byte with carry
        sta ptr1+1

        ; Compare first hash byte
        ldy #page_cache_entry::path_hash    ; First byte of entry hash
        lda (ptr1),y           ; Load entry hash byte 0
        cmp _find_params+page_cache_find_params::path_hash  ; Load find_params.path_hash low byte
        bne key_differs
        
        ; First byte matches, compare second byte
        iny                    ; Point to second byte of hash
        lda (ptr1),y           ; Load entry hash byte 1
        cmp _find_params+page_cache_find_params::path_hash+1  ; Load find_params.path_hash high byte
        bne key_differs
        
        ; Hash matches, compare group_id
        ; ldy #page_cache_entry::group_id     ; Point to group_id
        iny                     ; this is same as above as y is already tracking the struct entries, and group_id is next
        lda (ptr1),y           ; Load entry group_id
        cmp _find_params+page_cache_find_params::group_id  ; Load find_params.group_id
        bne key_differs
        
        ; Exact match found!
        inc _find_params+page_cache_find_params::found_exact  ; found_exact = 1
        lda tmp3               ; Load mid
        sta _find_params+page_cache_find_params::position  ; position = mid
        rts

adjust_right_norm:
        ; A = mid
        sec
        sbc #1                 ; mid - 1
        sta tmp2               ; right = mid - 1
        bcs binary_search       ; always, as mid will never overflow

adjust_left_norm:
        ; A = mid
        clc
        adc #1                 ; mid + 1
        sta tmp1               ; left = mid + 1
        bcc binary_search       ; always, as mid will never overflow

key_differs:
        ; we can pre-load tmp3 (mid) into A as it's used in all cases following and doesn't affect carry
        lda tmp3
        bcc adjust_left

adjust_right:
        ; Entry > Search, adjust right
        ; Check if left == mid
        cmp tmp1
        bne adjust_right_norm
        ; left == mid case

set_pos_return:
        sta _find_params+page_cache_find_params::position  ; position = mid
        rts

adjust_left:
        ; Check if right == mid
        cmp tmp2
        bne adjust_left_norm

        ; right == mid case
        clc
        adc #1                 ; mid + 1
        bcc set_pos_return

.endproc

; --------------------------------------------------------------------
; mul8
; --------------------------------------------------------------------

; multiply A by 8 into tmp1/tmp2
.proc mul8
        sta tmp1
        lda #0
        sta tmp2                                   ; tmp1/tmp2 = position as 16-bit
        asl tmp1                                   ; * 2
        rol tmp2
        asl tmp1                                   ; * 4
        rol tmp2
        asl tmp1                                   ; * 8
        rol tmp2
        rts
.endproc

; --------------------------------------------------------------------
; calc_entry_loc
; --------------------------------------------------------------------

; set entry_loc to the entry location we need for the new index, and for moving old data
.proc calc_entry_loc
        ; Calculate position * 8 for source address
        lda _find_params+page_cache_find_params::position
        jsr mul8    ; saves in tmp1/2

        ; Calculate source address: _cache+page_cache::entries + (position * 8)
        lda #<(_cache+page_cache::entries)
        clc
        adc tmp1                                   ; Add low byte
        sta entry_loc
        lda #>(_cache+page_cache::entries)
        adc tmp2                                   ; Add high byte with carry
        sta entry_loc+1
        rts
.endproc

; --------------------------------------------------------------------
; page_cache_insert
; --------------------------------------------------------------------

.proc _page_cache_insert
        ; Check if we have space
try_insert:
        lda _cache+page_cache::entry_count
        cmp #PAGE_CACHE_MAX_ENTRIES
        bcc have_space

        ; No space in index, try to free up space
        jsr try_free_space
        bne try_insert      ; If space was freed (A != 0), try again
        
        ; No space could be freed
        jmp no_space

have_space:
        ; Set up find_params from insert_params
        lda _insert_params+page_cache_insert_params::path_hash
        sta _find_params+page_cache_find_params::path_hash
        lda _insert_params+page_cache_insert_params::path_hash+1
        sta _find_params+page_cache_find_params::path_hash+1
        lda _insert_params+page_cache_insert_params::group_id
        sta _find_params+page_cache_find_params::group_id

        jsr _page_cache_find_position

        ; Check if entry already exists
        lda _find_params+page_cache_find_params::found_exact
        bne entry_exists

        ; this is common to both moving old indexes, and inserting new one, so calculate once
        jsr calc_entry_loc

        ; Calculate source and count for memmove if needed
        ldx _find_params+page_cache_find_params::position     ; Get insert position
        cpx _cache+page_cache::entry_count         ; Compare with entry_count
        bcs skip_move                              ; Skip if inserting at end

        ; Calculate number of entries to move
        lda _cache+page_cache::entry_count
        sec
        sbc _find_params+page_cache_find_params::position     ; A = count - position

        ; Calculate total bytes to move (count * 8), as 8 is size of cache index entry
        jsr mul8
        ; transfer to tmp3/4
        lda tmp1
        sta tmp3
        lda tmp2
        sta tmp4

        ; Calculate destination (source + 8)
        lda entry_loc
        clc
        adc #PAGE_CACHE_ENTRY_SIZE
        sta ptr2
        lda entry_loc+1
        adc #0
        sta ptr2+1

        ; Push destination address
        lda ptr2                                   ; Load dest address low byte
        ldx ptr2+1                                 ; Load dest address high byte
        jsr pushax

        ; Push source address
        lda entry_loc                              ; Load source address low byte
        ldx entry_loc+1                            ; Load source address high byte
        jsr pushax

        ; Load size for final parameter
        lda tmp3                                   ; Load size low byte
        ldx tmp4                                   ; Load size high byte
        jsr _memmove

skip_move:
        ; Insert new entry
        ; set ptr1 to dst
        lda entry_loc
        sta ptr1
        lda entry_loc+1
        sta ptr1+1

        ; Set up source pointer to insert_params
        lda #<_insert_params
        sta ptr2
        lda #>_insert_params
        sta ptr2+1

        ; Copy 8 bytes from insert_params to entry
        ldy #7                                     ; Start from last byte
copy_loop:
        lda (ptr2),y                              ; Load from insert_params
        sta (ptr1),y                              ; Store to entry
        dey
        bpl copy_loop                             ; Loop until y wraps (8 bytes)

        ; Update bank free space
        lda _insert_params+page_cache_insert_params::bank_id
        asl a                                      ; * 2 for word offset
        tay                                        ; Use as index

        ; Subtract group_size from bank_free_space[bank_id]
        lda _cache+page_cache::bank_free_space,y
        sec
        sbc _insert_params+page_cache_insert_params::group_size
        sta _cache+page_cache::bank_free_space,y
        iny
        lda _cache+page_cache::bank_free_space,y
        sbc _insert_params+page_cache_insert_params::group_size+1
        sta _cache+page_cache::bank_free_space,y

        ; Increment entry count
        inc _cache+page_cache::entry_count

        ; Set success = 1
        lda #1
        bne set_success

no_space:
entry_exists:
        ; Set success = 0
        lda #0

set_success:
        sta _insert_params+page_cache_insert_params::success
        rts
.endproc

; --------------------------------------------------------------------
; try_free_space
; Attempts to free up space by:
; 1. Trying to expel paths up to 3 times
; 2. If that doesn't work, removing entries one by one
; Returns:
;   A = 1 if space was freed, 0 if not
; --------------------------------------------------------------------
.proc try_free_space
        lda #0
        sta attempts       ; Reset attempts counter

try_expel:
        ; Check if we've tried expelling too many times
        lda attempts
        cmp #3
        bcs try_remove_entries  ; If attempts >= 3, try removing entries
        
        ; Increment attempts counter
        inc attempts
        
        ; Try to expel a path
        jsr _page_cache_expel_path
        
        ; Check if any entries were removed
        lda _remove_path_params+page_cache_remove_path_params::removed_count
        bne success       ; If entries removed, return success
        
try_remove_entries:
        ; Get first entry's hash and group_id
        lda _cache+page_cache::entries+page_cache_entry::path_hash
        sta _remove_group_params+page_cache_remove_group_params::path_hash
        lda _cache+page_cache::entries+page_cache_entry::path_hash+1
        sta _remove_group_params+page_cache_remove_group_params::path_hash+1
        lda _cache+page_cache::entries+page_cache_entry::group_id
        sta _remove_group_params+page_cache_remove_group_params::group_id
        
        ; Remove the entry
        jsr _page_cache_remove_group
        
        ; Entry was removed, return success
success:
        lda #1
        rts

failed:
        lda #0
        rts

.endproc

; --------------------------------------------------------------------
; page_cache_remove_group
; --------------------------------------------------------------------

.proc _page_cache_remove_group
        ; Set up find_params from remove_group_params
        lda _remove_group_params+page_cache_remove_group_params::path_hash
        sta _find_params+page_cache_find_params::path_hash
        lda _remove_group_params+page_cache_remove_group_params::path_hash+1
        sta _find_params+page_cache_find_params::path_hash+1
        lda _remove_group_params+page_cache_remove_group_params::group_id
        sta _find_params+page_cache_find_params::group_id

        ; Find the entry
        jsr _page_cache_find_position

        ; Check if entry exists
        lda _find_params+page_cache_find_params::found_exact
        bne found
        jmp not_found

found:
        ; Calculate entry location
        jsr calc_entry_loc        ; Will put entry address in entry_loc

        ; Copy entry_loc to ptr1 for indirect addressing
        lda entry_loc
        sta ptr1
        lda entry_loc+1
        sta ptr1+1

        ; Get bank_id and calculate offset into bank_free_space
        ldy #page_cache_entry::bank_id
        lda (ptr1),y
        sta bank_id             ; store it for later
        asl a                   ; * 2 for word offset - safe as banks max is 64
        tax                     ; Save in X for indexing bank_free_space

        ; Save the group size we'll use for all adjustments
        ldy #page_cache_entry::group_size
        lda (ptr1),y
        sta adjust_size
        iny
        lda (ptr1),y
        sta adjust_size+1

        ; Update bank free space - add group_size to bank_free_space[bank_id]
        lda _cache+page_cache::bank_free_space,x
        clc
        adc adjust_size        ; Use saved size
        sta _cache+page_cache::bank_free_space,x
        inx
        lda _cache+page_cache::bank_free_space,x
        adc adjust_size+1      ; Use saved size
        sta _cache+page_cache::bank_free_space,x

        ; Save our entry's bank_offset in tmp1/2
        ; and initialize highest_offset to our offset
        ldy #page_cache_entry::bank_offset
        lda (ptr1),y
        sta tmp1
        sta highest_offset
        iny
        lda (ptr1),y
        sta tmp2
        sta highest_offset+1
        
        ; Start scanning from beginning of entries
        lda #<(_cache+page_cache::entries)
        sta ptr1
        lda #>(_cache+page_cache::entries)
        sta ptr1+1
        
        ldx #0                  ; Entry counter
scan_loop:
        cpx _cache+page_cache::entry_count
        bne continue_scan
        jmp scan_done

continue_scan:        
        ; Check if this is our entry
        cpx _find_params+page_cache_find_params::position
        beq next_entry
        
        ; Check if same bank
        ldy #page_cache_entry::bank_id
        lda (ptr1),y           ; Get bank_id
        cmp bank_id
        bne next_entry
        
        ; Get this entry's offset
        iny                    ; Point to bank_offset
        lda (ptr1),y
        sta entry_offset
        iny
        lda (ptr1),y
        sta entry_offset+1
        
        ; save the entry's group size
        iny                    ; Point to group_size
        lda (ptr1),y
        sta group_size
        iny
        lda (ptr1),y
        sta group_size+1
        
        ; Compare with our offset (entry_offset > tmp1/2?)
        lda entry_offset+1     ; Compare high bytes first
        cmp tmp2
        bcc next_entry        ; If high byte less, definitely not greater
        bne calc_end_offset   ; If high byte greater, definitely greater
        lda entry_offset      ; High bytes equal, compare low bytes
        cmp tmp1
        bcc next_entry        ; If low byte less or equal, not greater
        beq next_entry        ; Equal case

calc_end_offset:
        ; Add group_size to get end offset for highest_offset calculation
        clc
        lda entry_offset
        adc group_size
        sta end_offset
        lda entry_offset+1
        adc group_size+1
        sta end_offset+1
        
        ; Update highest_offset if this is higher (entry_offset > highest_offset?)
        ; lda end_offset+1     ; Compare high bytes first
        cmp highest_offset+1
        bcc adjust_offset        ; If high byte less, definitely not greater
        bne update_highest    ; If high byte greater, definitely greater
        lda end_offset      ; High bytes equal, compare low bytes
        cmp highest_offset
        bcc adjust_offset        ; If low byte less or equal, not greater
        beq adjust_offset        ; Equal case


update_highest:
        ; lda end_offset - A is already end_offset
        sta highest_offset
        lda end_offset+1
        sta highest_offset+1

adjust_offset:
        ; Now adjust this entry's offset by subtracting the adjustment size
        sec
        lda entry_offset
        sbc adjust_size       ; Use saved adjustment size
        sta entry_offset      ; Save adjusted value
        lda entry_offset+1
        sbc adjust_size+1     ; Use saved adjustment size
        sta entry_offset+1
        
        ; Store adjusted offset back to entry
        ldy #page_cache_entry::bank_offset+1
        ; lda entry_offset
        sta (ptr1),y
        dey
        lda entry_offset
        sta (ptr1),y

next_entry:
        ; Move to next entry
        lda ptr1
        clc
        adc #PAGE_CACHE_ENTRY_SIZE
        sta ptr1
        bcc :+
        inc ptr1+1

        ; and increment our loop counter for all entries
:       inx
        jmp scan_loop

scan_done:
        ; Restore our entry pointer - why?
        lda entry_loc
        sta ptr1
        lda entry_loc+1
        sta ptr1+1
        
        ; Calculate total size to move
        sec
        lda highest_offset
        sbc tmp1              ; Subtract our offset
        sta move_size
        lda highest_offset+1
        sbc tmp2
        sta move_size+1
        
        ; If nothing to move, we're done with bank operations
        ora move_size
        bne move_bank
        jmp bank_done

move_bank:
        ; Switch to correct bank
        lda bank_id
        jsr _change_bank
        
        ; Get bank base address into ptr3/ptr4 for calculations
        lda #<$4000
        sta ptr3
        lda #>$4000
        stx ptr3+1
        
        ; Calculate source address (bank_base + offset + group_size)
        ; First add offset
        clc
        ; lda ptr3 - already in A
        adc tmp1              ; Add low byte of offset
        sta ptr2              ; Store in ptr2 for source
        lda ptr3+1
        adc tmp2              ; Add high byte of offset
        sta ptr2+1
        
        ; Now add group_size to get final source
        clc
        lda ptr2
        adc group_size        ; Add low byte of group_size
        sta ptr2              ; Store back in ptr2
        lda ptr2+1
        adc group_size+1      ; Add high byte of group_size
        sta ptr2+1
        
        ; Calculate destination address (bank_base + offset)
        lda ptr3
        clc
        adc tmp1              ; Add low byte of offset
        tay                   ; Save low byte for pushax
        lda ptr3+1
        adc tmp2              ; Add high byte of offset
        tax                     ; high byte for pushax
        tya                     ; low byte for pushax
        jsr pushax
        
        ; Push source address
        lda ptr2              ; Load source address
        ldx ptr2+1
        jsr pushax
        
        ; Push size
        lda move_size         ; Load size to move
        ldx move_size+1
        jsr _memmove

        ; reset to normal memory to access cache again
        jsr _set_default_bank

bank_done:
        ; Now continue with removing entry from index
        ; Remove entry from index by moving following entries up
        lda _cache+page_cache::entry_count
        sec
        sbc _find_params+page_cache_find_params::position     ; A = count - position
        beq last_entry                             ; If removing last entry, no move needed
        
        sec                     ; Set carry for sbc
        sbc #1                  ; Subtract 1 since position is included
        jsr mul8                                   ; Get number of bytes to move in tmp1/tmp2

        ; Set up memmove parameters
        lda entry_loc                              ; Destination is current entry
        ldx entry_loc+1
        jsr pushax

        ; Source is next entry
        ; lda entry_loc ; pushax doesn't change A or X
        clc
        adc #PAGE_CACHE_ENTRY_SIZE
        tay
        lda entry_loc+1
        adc #0
        tax
        tya
        jsr pushax

        ; Size is in tmp1/tmp2
        lda tmp1
        ldx tmp2
        jsr _memmove

last_entry:
        ; Decrement entry count
        dec _cache+page_cache::entry_count

        ; Set success = 1
        lda #1
        bne set_success        ; Always taken

not_found:
        lda #0
set_success:
        sta _remove_group_params+page_cache_remove_group_params::success
        rts

.endproc

; --------------------------------------------------------------------
; page_cache_remove_path
; --------------------------------------------------------------------
.proc _page_cache_remove_path
        ; Initialize removed count
        lda #0
        sta _remove_path_params+page_cache_remove_path_params::removed_count
        sta entry_index      ; Initialize entry index to 0
        
        ; Initialize entry pointer to start of entries
        lda #<(_cache+page_cache::entries)
        sta ptr2
        lda #>(_cache+page_cache::entries)
        sta ptr2+1
        
scan_loop:
        ; Check if we've reached the end
        lda entry_index
        cmp _cache+page_cache::entry_count
        bcs done
        
        ; Compare first hash byte
        ldy #0              
        lda (ptr2),y
        cmp _remove_path_params+page_cache_remove_path_params::path_hash  ; Compare with stored hash
        beq check_second    ; Equal, check second byte
        bcc next_entry     ; Less than target, keep scanning
        bcs done           ; Greater than target, we're done
        
check_second:
        ; First byte matches, check second byte
        iny                 
        lda (ptr2),y
        cmp _remove_path_params+page_cache_remove_path_params::path_hash+1  ; Compare with stored hash
        beq found_match     ; Equal, we found a match
        bcc next_entry     ; Less than target, keep scanning
        bcs done           ; Greater than target, we're done
        
found_match:
        ; Hash matches! Set up remove_group_params and call remove_group
        ; Get group_id from entry
        ldy #page_cache_entry::group_id
        lda (ptr2),y
        sta _remove_group_params+page_cache_remove_group_params::group_id
        
        ; Copy path hash to remove_group_params
        lda _remove_path_params+page_cache_remove_path_params::path_hash
        sta _remove_group_params+page_cache_remove_group_params::path_hash
        lda _remove_path_params+page_cache_remove_path_params::path_hash+1
        sta _remove_group_params+page_cache_remove_group_params::path_hash+1
        
        ; Call remove_group
        jsr _page_cache_remove_group
        
        ; Check if removal was successful
        lda _remove_group_params+page_cache_remove_group_params::success
        beq next_entry
        
        ; Removal succeeded, increment removed count
        inc _remove_path_params+page_cache_remove_path_params::removed_count
        
        ; Don't increment entry_index since entries shifted down
        bne scan_loop
        
next_entry:
        ; Move to next entry - add index size to ptr2
        lda ptr2
        clc
        adc #PAGE_CACHE_ENTRY_SIZE
        sta ptr2
        bcc :+
        inc ptr2+1
:       
        ; Move to next entry index
        inc entry_index
        bne scan_loop
        
done:
        rts

.endproc

; --------------------------------------------------------------------
; page_cache_find_free_bank
; Uses:
;   ptr1 = entry pointer for scanning
;   ptr2 = best_space (2 bytes)
;   tmp1 = best_bank (1 byte)
;   tmp2 = bank_index (1 byte)
;   tmp3/tmp4 = current bank space (2 bytes)
; --------------------------------------------------------------------

.proc _page_cache_find_free_bank
        ; First check if size is larger than bank can hold
        lda _find_bank_params+page_cache_find_bank_params::size_needed+1  ; High byte
        cmp #>BANK_SIZE
        bcc size_ok        ; If high byte less, definitely ok
        bne failed_size    ; If high byte greater, fail
        lda _find_bank_params+page_cache_find_bank_params::size_needed    ; Low byte
        cmp #<BANK_SIZE
        bcc size_ok        ; If low byte < BANK_SIZE low byte, ok

failed_size:
        jmp too_large     ; Too far for direct branch

size_ok:

try_alloc:
        ; Initialize best bank and space
        lda #$FF
        sta tmp1            ; best_bank = 0xFF (not found)
        lda #0
        sta ptr2           ; best_space low = 0
        sta ptr2+1         ; best_space high = 0
        sta tmp2           ; bank_index = 0
        
bank_loop:
        ; Get index into bank_free_space array (bank_index * 2)
        lda tmp2           ; bank_index
        asl                ; * 2 for word offset
        tay
        
        ; Load bank space into tmp3/tmp4
        lda _cache+page_cache::bank_free_space,y
        sta tmp3           ; Low byte
        iny
        lda _cache+page_cache::bank_free_space,y
        sta tmp4           ; High byte
        
        ; Skip if bank doesn't have enough space
        cmp _find_bank_params+page_cache_find_bank_params::size_needed+1
        bcc next_bank      ; If high byte less, skip
        bne check_entries  ; If high byte greater, check entries
        lda tmp3           ; High bytes equal, compare low
        cmp _find_bank_params+page_cache_find_bank_params::size_needed
        bcc next_bank      ; If low byte less, skip
        
check_entries:
        ; Initialize entry pointer
        lda #<(_cache+page_cache::entries)
        sta ptr1
        lda #>(_cache+page_cache::entries)
        sta ptr1+1
        
        ldx #0              ; entry counter
scan_loop:
        cpx _cache+page_cache::entry_count
        beq update_best     ; No matches, update best if better space
        
        ; Check if entry is in this bank
        ldy #page_cache_entry::bank_id
        lda (ptr1),y
        cmp tmp2           ; Compare with current bank_index
        bne next_entry
        
        ; Check path hash
        ldy #page_cache_entry::path_hash
        lda (ptr1),y        ; Load first byte of hash
        cmp _find_bank_params+page_cache_find_bank_params::path_hash
        bne next_entry
        iny
        lda (ptr1),y        ; Load second byte of hash
        cmp _find_bank_params+page_cache_find_bank_params::path_hash+1
        bne next_entry
        
        ; Found matching bank with enough space - use it!
        lda tmp2           ; Get bank_index
        sta _find_bank_params+page_cache_find_bank_params::bank_id
        rts
        
next_entry:
        ; Move to next entry
        lda ptr1
        clc
        adc #PAGE_CACHE_ENTRY_SIZE
        sta ptr1
        bcc :+
        inc ptr1+1
:       inx
        bne scan_loop
        
update_best:
        ; Compare with current best space
        lda tmp4           ; High byte
        cmp ptr2+1         ; Compare with best space high
        bcc next_bank      ; If less than best, try next
        bne set_best       ; If greater than best, update
        lda tmp3           ; High bytes equal, compare low
        cmp ptr2
        bcc next_bank      ; If less than best, try next
        beq next_bank      ; If equal, keep current
        
set_best:
        ; Update best values
        lda tmp3
        sta ptr2           ; best_space low
        lda tmp4
        sta ptr2+1         ; best_space high
        lda tmp2           ; bank_index
        sta tmp1           ; best_bank
        
next_bank:
        ; Move to next bank
        inc tmp2           ; bank_index++
        lda tmp2
        cmp _cache+page_cache::max_banks
        bne bank_loop
        
        ; Check if we found a bank with enough space
        lda tmp1
        cmp #$FF
        beq need_space      ; If no bank found, try freeing space
        
        ; Store best bank in result and return
        sta _find_bank_params+page_cache_find_bank_params::bank_id
        rts

need_space:
        ; Try to free up space
        jsr try_free_space
        beq too_large

        jmp try_alloc      ; If space was freed, try allocation again
        
too_large:
no_space:
        ; Return 0xFF to indicate no space found
        lda #$FF
        sta _find_bank_params+page_cache_find_bank_params::bank_id
        rts

.endproc

; --------------------------------------------------------------------
; page_cache_expel_path
; Uses:
;   ptr1 = pointer to current entry
; --------------------------------------------------------------------
.proc _page_cache_expel_path
        ; Initialize removed count to 0
        lda #0
        sta _remove_path_params+page_cache_remove_path_params::removed_count
        
        ; Exit early if no entries
        lda _cache+page_cache::entry_count
        beq done
        
        ; Initialize entry pointer to start of entries
        lda #<(_cache+page_cache::entries)
        sta ptr1
        lda #>(_cache+page_cache::entries)
        sta ptr1+1
        
        ldx #0              ; Entry counter
scan_loop:
        cpx _cache+page_cache::entry_count
        beq done           ; Reached end of entries
        
        ; Check if this entry has a different path hash
        ; First byte
        ldy #page_cache_entry::path_hash
        lda (ptr1),y
        cmp _find_bank_params+page_cache_find_bank_params::path_hash
        bne found_different
        
        ; Second byte
        iny
        lda (ptr1),y
        cmp _find_bank_params+page_cache_find_bank_params::path_hash+1
        bne found_different
        
next_entry:
        ; Move to next entry
        lda ptr1
        clc
        adc #PAGE_CACHE_ENTRY_SIZE
        sta ptr1
        bcc :+
        inc ptr1+1
:       inx
        bne scan_loop      ; Always taken as entry_count < 256
        
done:
        rts

found_different:
        ; Found entry with different hash, set up remove_path_params
        ldy #page_cache_entry::path_hash
        lda (ptr1),y        ; Get first byte of hash
        sta _remove_path_params+page_cache_remove_path_params::path_hash
        iny
        lda (ptr1),y        ; Get second byte of hash
        sta _remove_path_params+page_cache_remove_path_params::path_hash+1
        
        ; Call page_cache_remove_path
        jmp _page_cache_remove_path  ; Tail call optimization

.endproc

.bss
entry_loc:      .res 2
bank_id:        .res 1
group_size:     .res 2
highest_offset: .res 2
entry_offset:   .res 2
end_offset:     .res 2
move_size:      .res 2
adjust_size:    .res 2        ; New variable for storing how much to adjust by
entry_index:    .res 1        ; New variable for tracking current entry index
attempts:       .res 1        ; Counter for expel attempts
