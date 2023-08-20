        .export     _show_select

        .import     popax, popa
        .import     ascii_to_code
        .import     _fn_pause
        .import     _fn_get_scrloc
        .import     _malloc, _free
        .import     _fn_input_ucase

        .import     debug

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"
        .include    "fn_popup_item.inc"


; void fn_popup_select(char *msg, void *selected)
; 
; display a list of items, and show the values, allowing user to select from it
; using inverted text for selection
.proc _show_select
        ; axinto  fps_kb_handler          ; a kb handler to process key strokes while popup active
        axinto  fps_message             ; the header message to display in popup
        popax   fps_items               ; pointer to the PopupItems to display. contiguous piece of memory that needs breaking up into options and displays
        popa    fps_width               ; the width of the input area excluding the borders which add 1 each side for the border

        sta     fps_widget_idx          ; start on first widget
        mwa     fps_items, ptr1         ; set ptr1 to our popup data

        ; KEEP ptr1 SACRED

        ; border characters are: (screen codes)
        ; 4a  55 * width    4b
        ; 80  title         80
        ; c6  d5 x width    c7
        ; 59  ... lines     d9
        ; c8  55 * width    c9
        ; 4c  d5 x width    4f
        ; which leaves a box in middle size width+2 x height

        ; fixing y at 1st line (0) as it has a 4 pixel blank border, so nicely away from top border, but gives max room
        ; calculate the x-offset to show box. In the inner-box, it's (36 - width) / 2
        lda     #35     ; one off for border
        sec
        sbc     fps_width
        lsr     a       ; divide by 2
        tax             ; the x offset, in x!

        ; we'll manipulate screen location directly for speed, so only call scrloc once
        ldy     #$00
        jsr     _fn_get_scrloc          ; saves top left corner into ptr4. careful not to lose ptr4

        ; ----------------------------------------------------------
        ; show top line down
        mva     #$4a, tmp1
        mva     #$55, tmp2
        mva     #$4b, tmp3
        jsr     block_line

        ; ----------------------------------------------------------
        ; print the popup header message. let the caller worry about centring it with padded spaces
        adw     ptr4, #40
        mwa     fps_message, ptr2
        ; so that we can use same y index for both pointers, need to subtract 1 from ptr2, as y starts at 1
        sbw     ptr2, #$01

        ldy     #$00
        mva     #$80, {(ptr4), y}
        iny
        ldx     fps_width
:       lda     (ptr2), y
        jsr     ascii_to_code
        sta     (ptr4), y               ; copy letter to screen
        iny
        dex
        bne     :-
        mva     #$80, {(ptr4), y}

        ; ----------------------------------------------------------
        ; Under title
        adw     ptr4, #40
        mva     #$c6, tmp1
        mva     #$d5, tmp2
        mva     #$c7, tmp3
        jsr     block_line

; ----------------------------------------------------------
; L2 onwards we need to look at the popup data

; main loop for displaying different PopupItemType values
l_all_popups:
        ; add 40 to screen location to point to next line
        adw     ptr4, #40               ; add 1 line

        ldy     #$00
        lda     (ptr1), y       ; first byte of next popup entry
        cmp     #PopupItemType::finish
        bne     not_last_line
        jmp     do_last_line    ; check if we can branch here - might be too far

not_last_line:
        ; skip reading if the type is "space"
        cmp     #PopupItemType::space
        beq     start_switch

        pha     ; save the type while we read the whole line

        ; read the whole PopupItem entry
        mwa     #fps_pu_entry, ptr2     ; target for copy
        ldy     #$00
:       mva     {(ptr1), y}, {(ptr2), y}
        iny
        cpy     #.sizeof(PopupItem)
        bne     :-

        pla     ; restore the type

; ----------------------------------------------
; START SWITCH FOR TYPE

start_switch:

; --------------------------------------------------
; TEXT LIST
        cmp     #PopupItemType::textList
        bne     not_text_list

        mva     {fps_pu_entry + PopupItem::num}, tmp4
        mwa     {fps_pu_entry + PopupItem::text}, ptr2
        mva     #$11, tmp1              ; list number as screen code so don't have to convert it
        ; align ptr2 with Y being a 3 based index (it's screen offset)
        sbw     ptr2, #$03
all_text:

        jsr     left_border

        ; print digit for current index+1
        mva     tmp1, {(ptr4), y}
        iny
        mva     #$00, {(ptr4), y}
        iny

        ldx     fps_pu_entry + PopupItem::len
:       lda     (ptr2), y               ; fetch a character
        beq     no_trans                ; 0 conveniently maps to screen code for space, and is filler for end of string
        jsr     ascii_to_code
no_trans:
        sta     (ptr4), y
        iny
        dex
        bne     :-

        ; print spaces now until width chars printed to remove screen data for shorter lines
        ; this is important as we will shorten the line by 1 to allow the selection indicator char to be placed before border
:       cpy     fps_width
        beq     :+
        bcs     no_x_space      ; finish only when screen index > fps_width

:       lda     #$00
        sta     (ptr4), y
        iny
        bne     :--             ; always loop, exit will be when we are > width

no_x_space:
        ; right border
        mva     #$d9, {(ptr4), y}

        ; any more lines?
        dec     tmp4
        beq     :+

        ; move to next line, and next string, then reloop
        adw     ptr4, #40
        adw     ptr2, {fps_pu_entry + PopupItem::len}
        inc     tmp1                    ; next print index
        jmp     all_text

:
        jmp     item_handled

not_text_list:
; --------------------------------------------------
; OPTION
        cmp     #PopupItemType::option
        beq     is_option
        jmp     not_option

is_option:
        ; TODO: use border chars for highlighting chosen option
        mwa     {fps_pu_entry + PopupItem::spc}, ptr3           ; spacings ptr
        mwa     {fps_pu_entry + PopupItem::text}, ptr2          ; texts ptr

        jsr     left_border
        sty     tmp2                    ; screen position index over whole list, left border increments it by 1

        ; now print first string (name) from entry.text.
        ldy     #$00
:       lda     (ptr2), y
        beq     :+                      ; null terminated string
        jsr     ascii_to_code           ; convert to code
        iny
        sty     tmp1                    ; use tmp1 to store current index into string
        ldy     tmp2                    ; get the screen index pointer into y
        sta     (ptr4), y               ; print the character to screen
        iny
        sty     tmp2                    ; move pointer on screen on by 1
        ldy     tmp1                    ; restore character index
        bne     :-                      ; always. the exit it when we hit a 0 char

:       ; add the y+1 index (which points to 0 char of string) onto ptr2 to shift it to next string
        iny
        tya
        clc
        adc     ptr2
        sta     ptr2
        bcc     :+
        inc     ptr2+1

:       ldy     #$00
        sty     tmp1                    ; tmp1 now our main loop variable

widget_loop:
        jsr     print_widget_space
        sty     tmp2                    ; save new position

        ; y is doing double work here, it's the offset of 2 pointers; the current character to display, and the screen offset
        ; print the widget, ptr2 tracks the current widget location
        ldy     #$00
        ldx     fps_pu_entry + PopupItem::len                 ; number of chars to display for each widget
:       lda     (ptr2), y               ; get ascii char
        iny
        sty     tmp3                    ; save y (current character index)
        jsr     ascii_to_code           ; convert to screen code
        ldy     tmp2                    ; restorey screen offset
        sta     (ptr4), y               ; print char
        iny
        sty     tmp2
        ldy     tmp3                    ; get index of current char back into y
        dex
        bne     :-                      ; loop over len chars

        ; move ptr2 on by len to next string
        adw     ptr2, {fps_pu_entry + PopupItem::len}

        ; any more to process?
        inc     tmp1
        lda     tmp1
        tay                             ; the main loop is also index into space array, read at top of loop
        cmp     fps_pu_entry + PopupItem::num
        bne     widget_loop             ; reloop until all widgets done

        ; display final spacing so it overwrites any background text on the screen
        ; tmp1 holds index to last spacings
        ldy     tmp1
        jsr     print_widget_space

        ; right border
        mva     #$d9, {(ptr4), y}

        jmp     item_handled

not_option:
        cmp     #PopupItemType::space
        bne     not_space

        lda     #2
        jsr     _fn_pause
        jsr     debug

        ; just put a blank line. keyboard movement will skip over it
        mva     #$59, tmp1
        mva     #$00, tmp2
        mva     #$d9, tmp3
        jsr     block_line

        adw     ptr1, #$01              ; only 1 byte for space type
        jmp     l_all_popups

not_space:
; TODO: IMPLEMENT OTHER PopupItemType TYPES 


item_handled:
        adw     ptr1, #.sizeof(PopupItem)       ; move ptr1 to next popup entry
        jmp     l_all_popups

do_last_line:
        ; Pre last line
        mva     #$c8, tmp1
        mva     #$55, tmp2
        mva     #$c9, tmp3
        jsr     block_line

        ; last line
        adw     ptr4, #40
        mva     #$4c, tmp1
        mva     #$d5, tmp2
        mva     #$4f, tmp3
        jsr     block_line

        ; This is a mini version of gb keyboard handler that understands item types
        ; exit from here will exit the select screen
        jmp     show_select_kb

left_border:
        ldy     #$00
        mva     #$59, {(ptr4), y}
        iny
        rts

; Prints a block line on screen at current location
; tmp1 = TL char
; tmp2 = middle repeat char
; tmp3 = TR char
block_line:
        ldy     #$00
        mva     tmp1, {(ptr4), y}       ; left char
        iny
        ldx     fps_width
        lda     tmp2                    ; middle chars
:       sta     (ptr4), y
        iny
        dex
        bne     :-
        mva     tmp3, {(ptr4), y}       ; right char
        rts

; prints next amount of spaces to screen from spc array in ptr3
print_widget_space:
        lda     (ptr3), y               ; read number of spaces
        tax        
        ; print this many spaces
        lda     #$00
        ldy     tmp2
:       sta     (ptr4), y
        iny
        dex
        bne     :-
        rts
.endproc


; keep in same file for access to variables
.proc show_select_kb

start_kb_get:
        jsr     _fn_input_ucase
        cmp     #$00
        beq     start_kb_get

; --------------------------
; main kb switch

; valid keys are up/down/enter/esc/tab/left/right

; - enter selects current options that are highlighted
; - ESC always exits with no changes to be made (return '1' in A).
; - tab moves between widgets
; - in an option widget, L/R are allowed, not up/down
; - in a list, U/D allowed, L/R not
; - Space widget should be skipped

; Highlighting:
; - options text is inverted with 2 chars around current option
; - list entry is inverted for entire line
;
; Current selected is stored in popupItem.val for each item

        cmp     FNK_TAB
        bne     not_tab


not_tab:


        rts
.endproc


.bss
fps_pu_entry:   .tag PopupItem

fps_kb_handler: .res 2
fps_message:    .res 2
fps_items:      .res 2
fps_width:      .res 1
fps_widget_idx: .res 1  ; which widget we are currently on (do we just need type?)