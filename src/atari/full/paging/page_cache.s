        .export     _page_cache_find_position
        .export     _page_cache_find_free_bank
        .export     _page_cache_insert
        .export     _page_cache_remove_group
        .export     _page_cache_remove_path
        .export     _page_cache_init
        .export     _page_cache_get_pagegroup
        .export     _page_cache_set_path_filter

        .export     entry_loc
        .export     page_header

        .export     page_cache_buf

        .import     _cache
        .import     _find_bank_params
        .import     _find_params
        .import     _insert_params
        .import     _remove_group_params
        .import     _remove_path_params
        .import     _get_pagegroup_params
        .import     _path_filter
        .import     _set_path_flt_params

        .import     _bank_count
        .import     _change_bank
        .import     _get_bank_base
        .import     _set_default_bank

        .import     _div_i16_by_i8
        .import     _hash_string
        .import     _fc_strlcpy
        .import     _fc_strlcpy_params

        .import     _bzero
        .import     _memcpy
        .import     _memmove
        .import     pusha
        .import     pushax
        .import     return0
        .import     return1

        .import     _fuji_read_directory_block

        .include    "page_cache.inc"
        .include    "macros.inc"
        .include    "zp.inc"
        .include    "fc_strlcpy.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; page_cache_init(uint8_t max)
; Initialize the cache structure with the specified maximum number of banks
; Parameter is passed in A register
; --------------------------------------------------------------------
.proc _page_cache_init
        ; Store max_banks parameter
        sta     _cache+page_cache::max_banks
        beq     exit

        ; Calculate max_banks * 2 for array size (safe as max_banks <= 64)
        asl                 ; Double the value
        sta     tmp1           ; Store for comparison

        ; Initialize entry_count to 0
        lda     #0
        sta     _cache+page_cache::entry_count

        ; Initialize bank_free_space array - each bank starts with BANK_SIZE free space
        ldx     #0              ; Array index
init_banks:
        lda     #<BANK_SIZE
        sta     _cache+page_cache::bank_free_space,x
        inx
        lda     #>BANK_SIZE
        sta     _cache+page_cache::bank_free_space,x
        inx
        cpx     tmp1           ; Compare with max_banks * 2
        bne     init_banks

exit:
        rts
.endproc

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

; --------------------------------------------------------------------
; mul8
; multiply A by 8 into A/X. Destoys ptr4 (just 1 byte)
; --------------------------------------------------------------------
.proc mul8
        tax                     ; save the value we want to multiply while we setup high byte
        lda     #0
        sta     ptr4
        txa

        ; it's faster to rotate A (2 cycles), catch bits into high byte and finally have A as low byte
        ; than to shift zp (6 cycles each time)
        asl                     ; * 2
        rol     ptr4
        asl                     ; * 4
        rol     ptr4
        asl                     ; * 8
        rol     ptr4
        ; A = low byte already
        ldx     ptr4            ; high byte in X

        rts

; NOTES: I created a version that uses bcc/ora which was fewer cycles (15) when there are no bits to carry
; but was 35 bytes in length, and much less readable. It was 1 cycle longer only in the case when all 3 bits
; are set, so if we were optimising for speed, would be better.

.endproc

; --------------------------------------------------------------------
; calc_entry_loc
; --------------------------------------------------------------------

; set entry_loc to the entry location we need for the new index, and for moving old data
; parameters: A = index position to move to
; trashes ptr4/ptr4+1, X
.proc calc_entry_loc
        ; Calculate <index> * 8 for source address
        jsr     mul8    ; returns result in A/X
        axinto  ptr4

        ;; this macro doesn't work because of ".hibyte" trying to see if the literal is an address or 1 byte value.
        ; adw     ptr4, {#(_cache + page_cache::entries)}, entry_loc

        clc
        ; Calculate source address: _cache+page_cache::entries + (position * 8)
        lda     #<(_cache+page_cache::entries)
        adc     ptr4
        sta     entry_loc

        lda     #>(_cache+page_cache::entries)
        adc     ptr4+1
        sta     entry_loc+1

        rts
.endproc

; --------------------------------------------------------------------
; page_cache_insert
; --------------------------------------------------------------------

.proc _page_cache_insert
        ; Check if we have space
try_insert:
        lda     _cache+page_cache::entry_count
        cmp     #PAGE_CACHE_MAX_ENTRIES
        bcc     have_space

        ; No space in index, try to free up space
        jsr     try_free_space
        bne     try_insert      ; If space was freed (A != 0), try again

        ; No space could be freed
        jmp     no_space

have_space:
        ; Set up find_bank parameters from insert_params
        setax   _insert_params+page_cache_insert_params::group_size
        axinto  _find_bank_params+page_cache_find_bank_params::size_needed

        setax   _insert_params+page_cache_insert_params::path_hash
        axinto  _find_bank_params+page_cache_find_bank_params::path_hash

        ; Find a bank with enough space
        jsr     _page_cache_find_free_bank

        ; Check if we found a bank (A already contains the bank_id found)
        ; lda     _find_bank_params+page_cache_find_bank_params::bank_id
        cmp     #$FF
        bne     :+
        jmp     no_space

        ; Store the bank_id in insert_params
:       sta     _insert_params+page_cache_insert_params::bank_id

        ; Calculate bank offset from free space
        ; lda     _find_bank_params+page_cache_find_bank_params::bank_id
        asl     a              ; * 2 for word offset
        tay
        lda     #<BANK_SIZE
        sec
        sbc     _cache+page_cache::bank_free_space,y
        sta     _insert_params+page_cache_insert_params::bank_offset
        lda     #>BANK_SIZE
        sbc     _cache+page_cache::bank_free_space+1,y
        sta     _insert_params+page_cache_insert_params::bank_offset+1

        ; Set up find_params from insert_params for position search
        setax   _insert_params+page_cache_insert_params::path_hash
        axinto  _find_params+page_cache_find_params::path_hash
        lda     _insert_params+page_cache_insert_params::group_id
        sta     _find_params+page_cache_find_params::group_id

        jsr     _page_cache_find_position

        ; Check if entry already exists, 0 = not found, 1 = found exact
        lda     _find_params+page_cache_find_params::found_exact
        beq     :+

        ; TODO: decide if we sould remove the entry from the current cache, and re-insert it from the new data
        ; which would be pretty simple, as we have all the data
        jmp     entry_exists

        ; this is common to both moving old indexes, and inserting new one, so calculate once
:       lda     _find_params+page_cache_find_params::position
        jsr     calc_entry_loc

        ; Calculate source and count for memmove if needed
        lda     _find_params+page_cache_find_params::position     ; Get insert position
        cmp     _cache+page_cache::entry_count         ; Compare with entry_count
        bcs     skip_move                              ; Skip if inserting at end

        ; Calculate number of entries to move
        lda     _cache+page_cache::entry_count
        sec
        sbc     _find_params+page_cache_find_params::position     ; A = count - position

        ; Calculate total bytes to move (count * 8), as 8 is size of cache index entry
        jsr     mul8
        axinto  tmp3            ; goes into tmp3/4

        ; Calculate destination (source + PAGE_CACHE_ENTRY_SIZE)
        lda     entry_loc
        clc
        adc     #PAGE_CACHE_ENTRY_SIZE
        sta     ptr2
        lda     entry_loc+1
        adc     #0
        sta     ptr2+1

        ; Push destination address
        pushax  ptr2            ; dst ptr
        pushax  entry_loc       ; src ptr
        setax   tmp3            ; size (tmp3/tmp4)
        jsr     _memmove

skip_move:
        ; Insert new entry
        ; set ptr1 to dst
        mwa     entry_loc, ptr1

        ; Set up source pointer to insert_params
        mwa     #_insert_params, ptr2

        ; Copy PAGE_CACHE_ENTRY_SIZE bytes from insert_params to entry
        ; TODO: if we extend the page_cache entry data, need additional bytes here
        ldy     #PAGE_CACHE_ENTRY_SIZE-1        ; Start from last byte
copy_loop:
        lda     (ptr2),y        ; Load from insert_params
        sta     (ptr1),y        ; Store to entry
        dey
        bpl     copy_loop       ; Loop until y wraps (PAGE_CACHE_ENTRY_SIZE bytes)

        ; Update bank free space
        lda     _insert_params+page_cache_insert_params::bank_id
        asl     a               ; * 2 for word offset
        tay                     ; Use as index

        ; Subtract group_size (which includes additional 2 bytes for header) from bank_free_space[bank_id]
        lda     _cache+page_cache::bank_free_space,y
        sec
        sbc     _insert_params+page_cache_insert_params::group_size
        sta     _cache+page_cache::bank_free_space,y
        iny
        lda     _cache+page_cache::bank_free_space,y
        sbc     _insert_params+page_cache_insert_params::group_size+1
        sta     _cache+page_cache::bank_free_space,y


        ; Get bank base address
        jsr     _get_bank_base

        ; TODO check code here, macros are inefficiently loading ptr2 a lot
        axinto  ptr2

        ; Add offset to get destination address
        adw     ptr2, _insert_params+page_cache_insert_params::bank_offset
        ; add 2 bytes for the bulk data we are copying, the 2 header bytes will go in separately
        adw     ptr2, #$02

        pushax  ptr2

        pushax  _insert_params+page_cache_insert_params::data_ptr
        ; save the group size in tmp1/tmp2 so we can access it after changing banks
        mwa     _insert_params+page_cache_insert_params::group_size, tmp1
        ; the bulk copy should be 2 bytes less for the header bytes
        sbw     tmp1, #$02

        ; copy the header bytes into tmp3/4 while we are in banked mode
        ; note this does 2 bytes
        mwa     _insert_params+page_cache_insert_params::pg_flags, tmp3

        ; Switch to target bank for data copy
        ; this must be done at the last possible second, so we can continue to use all the _params data
        ; which are all in normal ram BANK location, so we can't access them after changing bank.
        lda     _insert_params+page_cache_insert_params::bank_id
        jsr     _change_bank

        ; the src/dst are in software stack, just need the size from tmp1/2 in A/X
        setax   tmp1
        jsr     _memcpy

        ; copy tmp3/4 to the start of the bank, first reduce ptr2 by 2 to point to start of memory
        sbw     ptr2, #$02
        ldy     #$00
        ; copy 2 bytes
        mway    tmp3, {(ptr2), y}

        ; reset to default bank to allow access to _cache
        jsr     _set_default_bank

        ; Increment entry count
        inc     _cache+page_cache::entry_count

        ; Set success = 1
        lda     #$01
        bne     set_success

no_space:
entry_exists:
        ; Set success = 0 (fail)
        lda     #$00

set_success:
        sta     _insert_params+page_cache_insert_params::success
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


; --------------------------------------------------------------------
; _page_cache_set_path_filter
; calculates a new hash for the given path and filter
; so that it doesn't have to be constantly calculated every page
; but only when it changes
; Parameters:
;   path         - the directory we are browsing
;   filter       - any filter we are using for the results
; --------------------------------------------------------------------
.proc _page_cache_set_path_filter
        ; calculate a hash for the path/filter
        ; use the buffer page_cache_buf for this as it will be overwritten anyway with data if we fetch
        pushax  #page_cache_buf
        setax   #$100
        jsr     _bzero

        ; Setup fc_strlcpy params
        mwa     #page_cache_buf, _fc_strlcpy_params+fc_strlcpy_params::dst
        mwa     _set_path_flt_params+page_cache_set_path_filter_params::path, _fc_strlcpy_params+fc_strlcpy_params::src
        mva     #$e0, _fc_strlcpy_params+fc_strlcpy_params::size
        jsr     _fc_strlcpy
        sta     tmp1                    ; length actually copied

        ; see if we have a filter to copy
        mwa     _set_path_flt_params+page_cache_set_path_filter_params::filter, ptr1
        ldy     #$00
        lda     (ptr1), y
        beq     no_filter

        ; yes, so append a "|" between path and filter so we can easily hash it and the parts are separated in case there are name/filter clashes
        mwa     page_cache_buf, ptr1
        lda     #'|'
        ldy     tmp1
        sta     (ptr1), y               ; add "|" to end of string

        inc     tmp1                    ; increase size as we added an extra char
        adw1    ptr1, tmp1              ; make ptr1 point to first character after "|"

        ; Setup fc_strlcpy params for filter
        mwa     ptr1, _fc_strlcpy_params+fc_strlcpy_params::dst
        mwa     _set_path_flt_params+page_cache_set_path_filter_params::filter, _fc_strlcpy_params+fc_strlcpy_params::src
        mva     #$1f, _fc_strlcpy_params+fc_strlcpy_params::size
        jsr     _fc_strlcpy

no_filter:
        ; hash page_cache_buf
        setax   #page_cache_buf
        jsr     _hash_string

        axinto  _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        rts
.endproc

; --------------------------------------------------------------------
; _page_cache_get_pagegroup
; Tries to get the given pagegroup out of cache, or fetches it from fujinet and stores it in cache (along with any other pagegroups fetched)
; Parameters in _get_pagegroup_params, type: page_cache_get_pagegroup_params
;   dir_position - the position that we would send to FN to set the location within the directory we are in (0 based)
;   page_size    - number of files per page, required when making fujinet call for data
;   data_ptr     - where to save the pagegroup held in cache
;
; Returns error status, 1 = error (not on page boundary), 0 = all ok, data copied
; --------------------------------------------------------------------
.proc _page_cache_get_pagegroup
        ; convert dir_position to a group_id (page group number), 0 based, by dividing by the page size.
        ; the div routine will perform faster division for page_size of 16, which is one reason to use that if possible

start:
        ; faster page 0 as we don't need to do division
        lda     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        ora     _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position+1
        beq     skip_calc

        pusha   _get_pagegroup_params+page_cache_get_pagegroup_params::page_size
        setax   _get_pagegroup_params+page_cache_get_pagegroup_params::dir_position
        jsr     _div_i16_by_i8          ; quotient in A, remainder in X

        ; we have an issue if page_size doesn't exactly divide into dir_position, as it means we're part way into a page.
        ; e.g. dir_position = 25, but page_size = 16, we're not on page 2, we're somewhere down page 2.
        ; that would potentially cause issues with page alignment to directory location
        cpx     #$00
        beq     divides_exactly

        ; error out
        jmp     return1

skip_calc:
divides_exactly:
        sta     _find_params+page_cache_find_params::group_id

        ; the caller should have called _page_cache_set_path to generate a hash
        ; copy it into find
        ; these 2 are equivalent to "mwa FOO, BAR" but go via A/X instead of just A, and are easier to read
        setax   _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        axinto  _find_params+page_cache_find_params::path_hash

        ; so now we have find params; path_hash, group_id
        ; find out if we have the data already, if not, fetch it and save it
        jsr     _page_cache_find_position
        lda     _find_params+page_cache_find_params::found_exact
        beq     not_in_cache

        ; yes, already retrieved this page, so return the data
        ; the index entry is set in _find_params::entry_loc
        ; that points to PAGE_CACHE_ENTRY_SIZE bytes of type page_cache_entry
        mwa     _find_params+page_cache_find_params::entry_loc, ptr1

        ; get the bank_offset into ptr2, this doesn't include the bank base offset
        ldy     #page_cache_entry::bank_offset
        mywa    {(ptr1), y}, ptr2

        jsr     _get_bank_base
        ; add A/X from _get_bank_base into ptr2, i.e. ptr2 += get_bank_base()
        clc
        adc     ptr2
        sta     ptr2
        txa
        adc     ptr2+1
        sta     ptr2+1

        ; get the page group size into tmp1/2
        iny
        mywa    {(ptr1), y}, tmp1

        ; we're in the right bank in memory, and have the offset and size of data
        ; so copy it to the target location. There's no protection here, if caller doesn't
        ; set a valid location to save to, bad things may happen.
        ; we have to copy as the bank isn't normally active in memory, so caller
        ; must supply somewhere to copy to.

        ; push dest/src for memcpy
        pushax  _get_pagegroup_params+page_cache_get_pagegroup_params::data_ptr
        pushax  ptr2            ; memcpy src

        ; set the correct bank just before the copy, as we are accessing _params blocks which are in normal bank memory, not RAM banks
        ldy     #page_cache_entry::bank_id
        lda     (ptr1), y               ; get bank_id
        jsr     _change_bank            ; doesn't affect y

        setax   tmp1            ; size
        jsr     _memcpy

        ; reset bank to normal memory, and return no error
        jsr     _set_default_bank
        jmp     return0

not_in_cache:

        ; call the user's fetching_cb routine as we're about to read data which will delay the screen
        ldx     #$00            ; mark this as the start
        jsr     run_callback

        ; do a directory block read from fujinet, and call insert for every entry we find
        pusha   #$08            ; 8 ram pages (256 * 8 = 2048)
        pusha   _get_pagegroup_params+page_cache_get_pagegroup_params::page_size
        setax   #page_cache_buf
        jsr     _fuji_read_directory_block

        ; was there an error? fuji calls return success status, so 1 is ok
        bne     copy_to_cache

        ; return error status of 1
exit_error:
        ldx     #$01            ; mark this as the end
        jsr     run_callback

        jmp     return1

copy_to_cache:
        ; now move all the pagegroup data from page_cache_buf into cache

        ; validate header
        mwa     #page_cache_buf, ptr1
        ldy     #$00

        ; first two bytes are marker "MF"
        lda     (ptr1), y
        cmp     #'M'
        bne     exit_error
        iny
        lda     (ptr1), y
        cmp     #'F'
        bne     exit_error

        ; then the header bytes count, 4
        iny
        lda     (ptr1), y
        cmp     #$04
        bne     exit_error

        ; then the number of page groups in the results
        iny
        lda     (ptr1), y
        beq     exit_error      ; exit if there were none

        sta     num_pgs         ; save the count of page groups in this block
        iny                     ; move to first byte of pagegroup data

        setax   _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        axinto  _insert_params+page_cache_insert_params::path_hash

ins_loop:
        ; copy header bytes for the pagegroup into structure.
        ldx     #$00
h_loop:
        lda     (ptr1), y
        sta     page_header, x
        iny
        inx
        cpx     #$05
        bne     h_loop

        ; now we need to copy the entries for the pagegroups, bytes 5 onwards
        lda     page_header+page_cache_pagegroup_header::group_id
        sta     _insert_params+page_cache_insert_params::group_id

        ; set the insert group_size and the data pointer
        lda     page_header+page_cache_pagegroup_header::data_size
        sta     _insert_params+page_cache_insert_params::group_size
        lda     page_header+page_cache_pagegroup_header::data_size+1
        sta     _insert_params+page_cache_insert_params::group_size+1

        ; add 2 for the header bytes for flags/num_entries
        adw     _insert_params+page_cache_insert_params::group_size, #$02

        ; add the flags and num entries from header to insert params
        lda     page_header+page_cache_pagegroup_header::flags
        sta     _insert_params+page_cache_insert_params::pg_flags

        lda     page_header+page_cache_pagegroup_header::num_entries
        sta     _insert_params+page_cache_insert_params::pg_entry_cnt

        ; data pointer is the 5th byte of this current page group. ptr1 will be moved each iteration so we are at start
        ; of each page group block by moving it forward according to the size of the previous pagegroup
        ; currently "(ptr1), y" points to the start of the data to copy, but we need its location directly
        ; so make ptr2 point to it
        mwa     ptr1, ptr2
        clc
        tya                     ; add y to ptr2
        adc     ptr2
        sta     ptr2
        bcc     :+
        inc     ptr2+1
:
        ; TODO, just set/add it directly to data_ptr rather than ptr2, i.e. fold above addition into next statement and remove need for ptr2 here

        ; now we can copy this location to data_ptr in insert
        mwa     ptr2, _insert_params+page_cache_insert_params::data_ptr

        ; everything is set in the _insert_params block for calling insert. it will handle memory/banks etc
        jsr     _page_cache_insert ; corrupts in here.

        ; check if it worked. 0 = fail, A is already set to success value
        ; lda     _insert_params+page_cache_insert_params::success
        bne     :+
        jmp     exit_error

:
        ; now loop for all the other entries in the cache.
        ; first move ptr1 on by the size of the page group and header
        ; these can't be combined as we have to use the carry in the high byte before moving onto second addition
        adw     ptr1, page_header+page_cache_pagegroup_header::data_size
        adw     ptr1, #$05

        ; now decrement the page count, and loop if we have more
        dec     num_pgs
        bne     ins_loop

        ldx     #$01            ; mark this as the end of the fetching
        jsr     run_callback

        ; finally after inserting into cache, we can jump back to top and retry
        ; as it should now be there. If it wasn't, well the fujinet should have errored
        ; we must have received the data we were after, if it's available
        ; or there was an error, which should have been detected after calling FN.
        jmp     start

.endproc

.proc run_callback
        lda     _get_pagegroup_params+page_cache_get_pagegroup_params::fetching_cb
        ora     _get_pagegroup_params+page_cache_get_pagegroup_params::fetching_cb+1
        bne     :+

        ; there wasn't one set, so just return
        rts

:       mwa     _get_pagegroup_params+page_cache_get_pagegroup_params::fetching_cb, cb_loc

        jmp     $ffff
cb_loc  = * - 2

        ; implicit rts from jmp.

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
num_pgs:        .res 1

page_header:    .tag page_cache_pagegroup_header

; this can't be in BANK as it's used for the data returned from fujinet, and then copied into
; cache, which is in RAM BANK, so won't be available to copy between
page_cache_buf: .res 2048
