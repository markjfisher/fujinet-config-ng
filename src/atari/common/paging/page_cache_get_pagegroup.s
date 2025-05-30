.export     _page_cache_get_pagegroup

.import     _change_bank
.import     _div_i16_by_i8
.import     _find_params
.import     _fuji_read_directory_block
.import     _get_bank_base
.import     _get_pagegroup_params
.import     _insert_params
.import     _memcpy
.import     _page_cache_find_position
.import     _page_cache_insert
.import     _set_default_bank
.import     _set_path_flt_params
.import     num_pgs
.import     page_cache_buf
.import     page_header
.import     pusha
.import     pushax
.import     return0
.import     return1

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "CODE2"

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

run_callback:
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