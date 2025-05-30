.export     calc_entry_loc

.import     _cache
.import     entry_loc
.import     mul8

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "CODE2"

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