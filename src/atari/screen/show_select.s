        .export     _show_select

        .import     popax, popa
        .import     ascii_to_code
        .import     _fn_pause
        .import     _fn_get_scrloc
        .import     _malloc, _free
        .import     _fn_input_ucase
        .import     _fn_strlen

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

        ; save the current screen location as start of display lines after the title
        mwa     ptr4, fps_lines_start
        adw     fps_lines_start, #40    ; it needs moving to next line, as we are on the "under title" line

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
        pha     ; save the type while we read the whole line
        jsr     copy_entry
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
        adw1    ptr2, {fps_pu_entry + PopupItem::len}
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
        ldy     tmp2                    ; restore screen offset
        sta     (ptr4), y               ; print char
        iny
        sty     tmp2
        ldy     tmp3                    ; get index of current char back into y
        dex
        bne     :-                      ; loop over len chars

        ; move ptr2 on by len to next string
        adw1    ptr2, {fps_pu_entry + PopupItem::len}

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

        ; just put a blank line. keyboard movement will skip over it
        mva     #$59, tmp1
        mva     #$00, tmp2
        mva     #$d9, tmp3
        jsr     block_line

        ; UNCOMMENT IF MORE OPTIONS IMPLEMENTED
        ; jmp     item_handled

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

copy_entry:
        ; read the whole PopupItem entry into ptr2
        mwa     #fps_pu_entry, ptr2     ; target for copy
        ldy     #$00
:       mva     {(ptr1), y}, {(ptr2), y}
        iny
        cpy     #.sizeof(PopupItem)
        bne     :-
        rts

.endproc


; allows new scoping, but also access to everything in this file
.proc show_select_kb

        jsr     highlight_options

start_kb_get:
        jsr     _fn_input_ucase
        cmp     #$00
        beq     start_kb_get

; --------------------------------------------------------------------
; main popup select  kb switch
; --------------------------------------------------------------------

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
; Current selected is stored in popupItem.val for each item, 0 index

; --------------------------------------------------------------------
; TAB - switch widget
; --------------------------------------------------------------------
        cmp     #FNK_TAB
        bne     not_tab



        jmp     start_kb_get

not_tab:
; --------------------------------------------------------------------
; ENTER - finish interaction
; --------------------------------------------------------------------
        cmp     #FNK_ENTER
        bne     not_enter

        jmp     start_kb_get

not_enter:
; --------------------------------------------------------------------
; LEFT - option only
; --------------------------------------------------------------------
        cmp     #FNK_LEFT
        beq     is_left
        cmp     #FNK_LEFT2
        bne     not_left


is_left:
        jmp     start_kb_get

not_left:
; --------------------------------------------------------------------
; RIGHT - option only
; --------------------------------------------------------------------
        cmp     #FNK_RIGHT
        beq     is_right
        cmp     #FNK_RIGHT2
        bne     not_right

is_right:
        jmp     start_kb_get

not_right:
; --------------------------------------------------------------------
; UP - list only
; --------------------------------------------------------------------
        cmp     #FNK_UP
        beq     is_up
        cmp     #FNK_UP2
        bne     not_up
is_up:
        jmp     start_kb_get

not_up:
; --------------------------------------------------------------------
; DOWN - list only
; --------------------------------------------------------------------
        cmp     #FNK_DOWN
        beq     is_down
        cmp     #FNK_DOWN2
        bne     not_down
is_down:
        jmp     start_kb_get

not_down:
; --------------------------------------------------------------------
; ESC - leave processing
; --------------------------------------------------------------------
        cmp     #FNK_ESC
        bne     not_esc
        ldx     #$00
        lda     #$01
        rts

not_esc:
        jmp     start_kb_get


highlight_options:
        ; take the current selection, and widget index, and highlight the right things

        ; highlight the current selection on each item
        mwa     fps_items, ptr1                 ; first entry
        mwa     fps_lines_start, ptr3           ; ptr3 is our moving screen location per widget

; loop around all the entries until we hit exit
all_entries:
        jsr     _show_select::copy_entry        ; expects ptr1 to point to a PopupItem
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
        ; get current selection
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

        ; need to increment ptr3 over rest of lines so it starts at the next widget
        ; i.e. (num - tmp1) * 40
        lda     fps_pu_entry + PopupItem::num
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
        iny                     ; for the left hand border
        ldx     fps_pu_entry + PopupItem::len
:       lda     (ptr3), y
        ora     #$80
        sta     (ptr3), y
        iny
        dex
        bne     :-

        ; add 40 to ptr3 to point to next line
        adw     ptr3, #40

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
        adw     ptr1, #.sizeof(PopupItem)
        jmp     all_entries

end_hl:
        ; superhighlight the current widget's chosen option

        rts
.endproc


.bss
fps_pu_entry:   .tag PopupItem

fps_kb_handler: .res 2
fps_message:    .res 2
fps_items:      .res 2
fps_width:      .res 1
fps_widget_idx: .res 1  ; which widget we are currently on (do we just need type?)
fps_lines_start: .res 2