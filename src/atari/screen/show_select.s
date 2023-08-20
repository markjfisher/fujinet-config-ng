        .export     _show_select

        .import     popax, popa
        .import     ascii_to_code
        .import     _fn_pause
        .import     _fn_get_scrloc
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
        axinto  fps_kb_handler          ; a kb handler to process key strokes while popup active
        popax   fps_message             ; the header message to display in popup
        popax   fps_items               ; pointer to the PopupItems to display. contiguous piece of memory that needs breaking up into options and displays
        popa    fps_width               ; the width of the input area excluding the borders which add 2 each side (space and border)

        mva     #$00, fps_selected      ; default to first line
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

        ; fixing y at 1st line (0) as it has a 4 pixel blank border
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
        pha     ; save the type while we read the whole line

        ; read the whole PopupItem entry
        iny
        mva     {(ptr1), y}, fps_num
        iny
        mva     {(ptr1), y}, fps_len
        iny
        mva     {(ptr1), y}, fps_val    ; this is the initial selection too, and where we store results
        iny
        lda     (ptr1), y
        sta     fps_text
        iny
        lda     (ptr1), y
        sta     fps_text+1

        pla     ; restore the type

; ----------------------------------------------
; START SWITCH FOR TYPE

; --------------------------------------------------
; TEXT LIST
        cmp     #PopupItemType::textList
        bne     not_text_list

        mva     fps_num, tmp4
        mwa     fps_text, ptr2
        ; align ptr2 with Y being a 1 index (it's screen offset)
        sbw     ptr2, #$01
all_text:

        jsr     left_border
        ; current string into ptr2

        ldx     fps_width
:       lda     (ptr2), y               ; fetch a character
        beq     no_trans                ; 0 conveniently maps to screen code for space, and is filler for end of string
        jsr     ascii_to_code
no_trans:
        sta     (ptr4), y
        iny
        dex
        bne     :-
        ; right border
        mva     #$d9, {(ptr4), y}

        ; any more lines?
        dec     tmp4
        beq     :+

        ; move to next line, and next string, then reloop
        adw     ptr4, #40
        adw     ptr2, fps_width
        jmp     all_text

:
        jmp     item_handled

not_text_list:
; --------------------------------------------------
; OPTION
        cmp     #PopupItemType::option
        bne     not_option

        ; do an option
        jsr     left_border

        jmp     item_handled

not_option:        
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

        lda     #2
        jsr     _fn_pause
        jsr     debug

        rts

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

.endproc

.bss
fps_kb_handler: .res 2
fps_message:    .res 2
fps_items:      .res 2
fps_width:      .res 1
fps_selected:   .res 1
fps_text:       .res 2

fps_num:        .res 1
fps_len:        .res 1
fps_val:        .res 1
