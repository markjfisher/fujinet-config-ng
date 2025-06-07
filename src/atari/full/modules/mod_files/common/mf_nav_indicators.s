        .export     clear_status_2
        .export     show_prev
        .export     show_next
        .export     put_mf_s

        .import     ascii_to_code
        .import     mf_prev
        .import     mf_next
        .import     sline2

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

.segment "CODE2"

; Clear navigation indicators from status line (8 chars from each end)
clear_status_2:
        ; ONLY CLEAR 8 FROM EACH END
        mwa     #sline2, ptr1
        ldy     #8
        lda     #FNC_FULL
:       sta     (ptr1), y
        dey
        bpl     :-

        adw1    ptr1, #SCR_WIDTH-9
        ldy     #8
        lda     #FNC_FULL
:       sta     (ptr1), y
        dey
        bpl     :-

        rts

; Show "Prev" indicator on left side of status line
show_prev:
        mwa     #sline2, ptr1
        adw1    ptr1, #$01      ; 1 char into line
        mwa     #mf_prev, ptr2
        bne     put_mf_s        ; always, the high byte is never 0

; Show "Next" indicator on right side of status line
show_next:
        mwa     #sline2, ptr1
        adw1    ptr1, #(SCR_WIDTH - 8)          ; string is 8 chars, adjust for end of line
        mwa     #mf_next, ptr2
        ; fall through to print

; Helper function to print navigation strings
; ptr1 = screen location, ptr2 = string to print
put_mf_s:
        ldy     #$00
:       lda     (ptr2), y
        beq     :+              ; string terminator
        jsr     ascii_to_code
        sta     (ptr1), y
        iny
        bne     :-
:       rts 