.export try_free_space
.import _cache

.include "page_cache.inc"

.bss
mock_return:     .res 1  ; What the mock should return

.data
default_return:  .byte 0 ; Default to returning 0 (no space freed)

.code

; Mock version of try_free_space
; Returns value in mock_return (0 = no space freed, non-zero = space freed)
; When returning success, updates bank 0's free space to 16KB
try_free_space:
        lda     mock_return
        beq     no_space        ; If returning 0, don't modify space

        ; Set bank 0's free space to 16KB ($4000)
        lda     #$00
        sta     _cache+page_cache::bank_free_space
        lda     #$40
        sta     _cache+page_cache::bank_free_space+1

        lda     mock_return     ; Return success
        rts

no_space:
        lda     #0              ; Return failure
        rts

; Helper to set what the mock should return
.export _set_mock_try_free_space
_set_mock_try_free_space:
        sta     mock_return
        rts 