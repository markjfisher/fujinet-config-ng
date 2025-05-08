        .export     display_string

        .import     ascii_to_code
        .import     di_current_item
        .import     left_border
        .import     put_s_p1p4_at_y
        .import     return0
        .import     right_border
        .import     ss_pu_entry
        .import     ss_widget_idx

        .import     debug

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

; Editable string for popup items.
;
; NUM     = 1 at the moment, could have an ARRAY of strings if implement more!!
; LEN     = max length of the string including nul, so strlen of string can only be LEN-1 max
; VAL     = ptr to memory where string is stored
; TEXT    = ptr to string to put in front of editable
; VPWIDTH = width of the viewport we should show this string in.

; display the Name
; if this is highlighted line, display arrow
; display VAL up to VPWIDTH chars
; pad with inverse spaces
; display arrow if required

; ptr1 is tracking the current widget RODATA, but has been copied to ss_pu_entry, must be restored
; ptr4 is currently set to screen location to start printing widget line
; ss_pu_entry is a copy of the current widget data

; tmp1,tmp2,tmp5,tmp6,tmp9,tmp10
; ptr1,ptr2,ptr4
.proc display_string
        ; save ptr1, as it will be trashed by print routine
        mwa     ptr1, tmp9

        ; initialise flag to say if we're current widget
        ; mva     #$00, tmp1

        ; get the TEXT to display into ptr2
        mwa     {ss_pu_entry + PopupItemString::text}, ptr1
        sbw1    ptr1, #1                ; adjust it so the y index reads correct chars as it moves along screen (i.e. account for border forcing y = 1)

        ; get the memory location of the string we are editing into tmp5/6
        mwa     {ss_pu_entry + POPUP_VAL_IDX}, tmp5

; -----------------------------------------------------
; LEFT BORDER

        jsr     left_border             ; start the widget line

; -----------------------------------------------------
; TEXT
        ; print the TEXT value. y is currently 1, ptr4+y is good, but we had to adjust ptr1 to allow for this
        jsr     put_s_p1p4_at_y

; -----------------------------------------------------
; ARROW1
        ; is this the current widget?
        lda     ss_widget_idx
        cmp     di_current_item
        bne     not_current_widget

        ; this is current widget, mark flag so we know to close the arrow later
        mva     #FNC_L_HL, {(ptr4), y}  ; print the left side indicator arrow
        iny
        mva     #FNC_LEND_ST, {(ptr4), y}  ; print the closing ender
        bne     over1

not_current_widget:
        mva     #FNC_BLANK, {(ptr4), y} ; wasn't current line, just print 1 space and the opener
        iny
        mva     #FNC_L_END, {(ptr4), y}

over1:
        iny

        ; subtract Y from tmp5/6 (pointer to VALUE) so we can use offset correctly
        tya
        sbw1    tmp5, a

; -----------------------------------------------------
; EDITABLE STRING
        ; print the string, with inverted text, when we hit nul char, print spaces to end of view port width
        ; Limit the width to the vpWidth value for the popup.

        ; modify which routine is called to alter each letter for display based on popup type.
        lda     ss_pu_entry             ; first byte is type
        cmp     #PopupItemType::password
        beq     print_stars
        ; this is normal text, call ascii_to_code
        mwa     #ascii_to_code, {smc_alter_char + 1}

do_print:
        ldx     #$00                    ; track the string size as we print it
:       lda     (tmp5), y               ; get a char from string
        beq     do_padding              ; nul found

smc_alter_char:
        jsr     $0000                   ; this is modified to the appropriate location: WARNING - MAKES IT NON ROMMABLE
        ora     #$80                    ; invert it
        sta     (ptr4), y               ; show it on screen
        inx
        iny
        ; have we hit the viewport width?
        cpx     ss_pu_entry + PopupItemString::vpWidth
        bcc     :-
        bcs     do_padding

load_star:
        ; we just override with a * char whatever is in A
        lda     #FNC_STAR
        rts

print_stars:
        ; make the translation routine be load_star instead
        mwa     #load_star, {smc_alter_char + 1}
        jmp     do_print


; -----------------------------------------------------
; STRING PADDING
do_padding:
        lda     ss_pu_entry + PopupItemString::vpWidth
        sta     tmp2
        lda     #FNC_FULL
        ; print inverted spaces until x is string width
:       cpx     tmp2
        beq     :+
        sta     (ptr4), y
        inx
        iny
        bne     :-

; -----------------------------------------------------
; RIGHT CLOSER
:       mva     #FNC_R_END, {(ptr4), y}
        iny

; -----------------------------------------------------
; RIGHT BORDER
:       jsr     right_border

        mwa     tmp9, ptr1              ; restore ptr1
        jmp     return0
.endproc
