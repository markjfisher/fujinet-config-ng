.export     _page_cache_set_bank_size
.export     _page_cache_get_bank_size

.import     _cache

.include    "page_cache.inc"
.include    "macros.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; page_cache_set_bank_size(uint16_t bank_size)
; Set the configurable bank size
; Parameters: A/X = bank_size (little endian: A=low, X=high)
; --------------------------------------------------------------------
.proc _page_cache_set_bank_size
        sta     _cache+page_cache::bank_size      ; Store low byte
        stx     _cache+page_cache::bank_size+1    ; Store high byte
        rts
.endproc

; --------------------------------------------------------------------
; page_cache_get_bank_size()
; Get the current bank size
; Returns: A/X = bank_size (little endian: A=low, X=high)
; --------------------------------------------------------------------
.proc _page_cache_get_bank_size
        lda     _cache+page_cache::bank_size      ; Load low byte
        ldx     _cache+page_cache::bank_size+1    ; Load high byte
        rts
.endproc 