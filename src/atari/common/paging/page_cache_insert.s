.export     _page_cache_insert
.export     saved_dest

.import     _cache
.import     _change_bank
.import     _find_bank_params
.import     _find_params
.import     _get_bank_base
.import     _insert_params
.import     _memcpy
.import     _memmove
.import     _page_cache_find_free_bank
.import     _page_cache_find_position
.import     _set_default_bank
.import     calc_entry_loc
.import     entry_loc
.import     mul8
.import     pushax
.import     try_free_space

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "BANK"

saved_dest:     .res    2       ; Storage for ptr2 during _memcpy call

.segment "CODE2"

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

        ; Get bank base address into A/X
        jsr     _get_bank_base

        ; add 2 to A, increment X if carry set
        clc
        adc     #$02
        bcc     :+
        inx
        clc

        ; now add bank_offset
:       adc     _insert_params+page_cache_insert_params::bank_offset
        bcc     :+
        inx
        clc

        ; A/X = base + bank_offset + 2
        ; save it into our temp location so we can use it after the memcpy
:
        axinto  saved_dest

        jsr     pushax          ; dst for memcpy

        ; src for memcpy
        pushax  _insert_params+page_cache_insert_params::data_ptr
        ; save the group size in tmp1/tmp2 so we can access it after changing banks
        mwa     _insert_params+page_cache_insert_params::group_size, tmp1
        ; the copy from pagegroup data should be 2 bytes less as datasize includes 2 for the header bytes
        sbw     tmp1, #$02

        ; copy the header bytes into tmp3/4 while we are in banked mode
        ; note this does 2 bytes
        mwa     _insert_params+page_cache_insert_params::pg_flags, tmp3

        ; Switch to target bank for data copy
        ; this must be done at the last possible second, so we can continue to use all the _params data
        ; which are all in normal ram BANK location, so we can't access them after changing bank.
        lda     _insert_params+page_cache_insert_params::bank_id
        jsr     _change_bank            ; doesn't affect y

        ; the src/dst are in software stack, just need the size from tmp1/2 in A/X
        setax   tmp1
        jsr     _memcpy

        ; restore the destination+2 after memcpy
        mwa     saved_dest, ptr2

        ; copy tmp3/4 to the start of the bank, first reduce ptr2 by 2 to point to start of memory
        sbw     ptr2, #$02
        ldy     #$00
        ; copy 2 bytes
        nop
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