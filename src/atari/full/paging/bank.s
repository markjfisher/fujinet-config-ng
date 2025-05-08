        .export         _change_bank
        .export         _get_bank_base
        .export         _set_default_bank

        .import         _bank_count
        .import         _bank_table
        .import         return0
        .import         return1

        .include        "atari.inc"

.segment "CODE"

; bool change_bank(uint8_t bank_id)
;
; Change memory at $4000 to $7FFF to specified bank index.
; bank_id is 0 based index into stored banks in bank_table
; which is calculated at init. If the index is too high, this does nothing but returns an error status (1)
; otherwise it changes to the bank and returns 0

_change_bank:
        cmp     _bank_count
        bcs     @cb_error

        tax
        lda     _bank_table, x
        ; sanity check it's set
        beq     @cb_error

        sta     PORTB
        jmp     return0

@cb_error:
        jmp     return1


; void set_default_bank(void)
;
; changes to the
_set_default_bank:
        lda     #$ff
        sta     PORTB
        rts

; TODO: inline this once happy with testing
_get_bank_base:
        lda #<$4000
        ldx #>$4000
        rts

