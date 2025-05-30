.export     _page_cache_init

.import     _cache

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

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