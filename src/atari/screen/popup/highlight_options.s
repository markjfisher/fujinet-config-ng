        .export     highlight_options

        .import     _fn_strlen

        .import     copy_entry

        .import     fps_items
        .import     fps_scr_l_strt
        .import     fps_pu_entry
        .import     fps_widget_idx

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_popup_item.inc"

; take the current selection, and widget index, and highlight the right things
.proc highlight_options

        mwa     fps_items, ptr1                 ; first entry
        mwa     fps_scr_l_strt, ptr3            ; ptr3 is our moving screen location per widget
        mva     #$00, tmp3                      ; track which widget we're on, and superhighlight it if it matches current

; loop around all the entries until we hit exit
all_entries:
        jsr     copy_entry        ; expects ptr1 to point to a PopupItem
        lda     fps_pu_entry + PopupItem::type
        cmp     #PopupItemType::finish
        bne     not_finish
        jmp     end_hl

not_finish:
; ---------------------------------------------------------------------------
; textList
; ---------------------------------------------------------------------------
        cmp     #PopupItemType::textList
        bne     not_text_list

        ; get current selection within the texts to display
        lda     fps_pu_entry + PopupItem::val
        sta     tmp1

        ; loop through the entries until we are on current selection
        ldx     #$00
:       cpx     tmp1
        beq     found_line
        adw     ptr3, #40
        inx
        bne     :-

found_line:
        ; highlight the text from ptr3+3 to ptr3+entry::len
        ldy     #$03
        ldx     fps_pu_entry + PopupItem::len
:       lda     (ptr3), y
        ora     #$80
        sta     (ptr3), y
        iny
        dex
        bne     :-

        ; is this current list selection?
        lda     fps_widget_idx
        cmp     tmp3
        bne     :+

        ; yes, super highlight the entry at ptr3+2, and ptr3+len+2 as we are currently editing this list item
        ldy     #$02
        lda     #FNC_L_HL
        sta     (ptr3), y

        lda     fps_pu_entry + PopupItem::len
        clc
        adc     #$03            ; adjust for the list count spacing
        tay
        lda     #FNC_R_HL
        sta     (ptr3), y


        ; need to increment ptr3 over rest of lines so it starts at the next widget
        ; i.e. (num - tmp1) * 40
:       lda     fps_pu_entry + PopupItem::num
        sec
        sbc     tmp1
        tax
:       adw     ptr3, #40
        dex
        bne     :-

        jmp     next_entry

not_text_list:
; ---------------------------------------------------------------------------
; option
; ---------------------------------------------------------------------------
        cmp     #PopupItemType::option
        bne     not_option

        ; get string length of name into tmp2, this will be our offset to the option to highlight
        setax   fps_pu_entry + PopupItem::text
        jsr     _fn_strlen
        sta     tmp2
        inc     tmp2    ; add 1 for border

        lda     fps_pu_entry + PopupItem::val
        sta     tmp1

        ; add the spacer offsets up to chosen item into tmp2
        ldy     #$00
        mwa     {fps_pu_entry + PopupItem::spc}, ptr2        ; begining of offsets
:       lda     (ptr2), y
        clc
        adc     tmp2
        sta     tmp2
        iny
        cpy     tmp1
        bcc     :-
        beq     :-

        ; add lengths of previous option texts until hit current selected option
        ldx     #$00
:       cpx     tmp1
        beq     found_option
        lda     tmp2
        clc
        adc     fps_pu_entry + PopupItem::len
        sta     tmp2
        inx
        bne     :-

found_option:
        ldy     tmp2
        ldx     fps_pu_entry + PopupItem::len
:       lda     (ptr3), y
        ora     #$80
        sta     (ptr3), y
        iny
        dex
        bne     :-

        ; is this current list selection?
        lda     fps_widget_idx
        cmp     tmp3
        bne     :+

        ; yes, put HL chars around the field
        ldy     tmp2
        dey
        lda     #FNC_L_HL
        sta     (ptr3), y
        tya
        clc
        adc     fps_pu_entry + PopupItem::len
        tay
        iny
        lda     #FNC_R_HL
        sta     (ptr3), y


        ; add 40 to ptr3 to point to next line
:       adw     ptr3, #40

        jmp     next_entry

not_option:
; ---------------------------------------------------------------------------
; space
; ---------------------------------------------------------------------------
        cmp     #PopupItemType::space
        bne     not_space
        ; add a line to the screen pointer
        adw     ptr3, #40
        ; drop through

not_space:

next_entry:
        inc     tmp3            ; increment which widget the next one will be
        adw     ptr1, #.sizeof(PopupItem)
        jmp     all_entries

end_hl:
        rts
.endproc