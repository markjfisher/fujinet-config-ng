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

        ; Initialize bank_size to default if not already set
        lda     _cache+page_cache::bank_size
        ora     _cache+page_cache::bank_size+1
        bne     bank_size_set           ; Skip if already initialized

        ; Set default bank size
        lda     #<BANK_SIZE_DEFAULT
        sta     _cache+page_cache::bank_size
        lda     #>BANK_SIZE_DEFAULT
        sta     _cache+page_cache::bank_size+1

bank_size_set:
        ; Calculate max_banks * 2 for array size (safe as max_banks <= 64)
        lda     _cache+page_cache::max_banks
        asl                     ; Double the value
        sta     tmp10           ; Store for comparison

        ; Initialize entry_count to 0
        lda     #0
        sta     _cache+page_cache::entry_count

        ; Initialize bank_free_space array - each bank starts with bank_size free space
        ldx     #0              ; Array index
init_banks:
        lda     _cache+page_cache::bank_size      ; Use configurable bank size
        sta     _cache+page_cache::bank_free_space,x
        inx
        lda     _cache+page_cache::bank_size+1
        sta     _cache+page_cache::bank_free_space,x
        inx
        cpx     tmp10           ; Compare with max_banks * 2
        bne     init_banks

exit:
        rts
.endproc 