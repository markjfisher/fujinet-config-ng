        .export _change_bank
        .export _get_bank_base

_change_bank:
        rts

_get_bank_base:
        lda     #<$4000
        ldx     #>$4000
        rts
