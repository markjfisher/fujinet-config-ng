        .export     _show_select

        .import     popax, popa
        .import     ascii_to_code
        .import     _fn_pause
        .import     _fn_get_scrloc
        .import     fn_mul, fn_div
        .import     _malloc, _free
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
        popa    fps_width               ; the width of the input area excluding the borders which add 1 each side for the border

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

        ldx     fps_width               ; TODO: THIS SHOULD BE LEN, and centred in width

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

        ; calculate space around widgets to evenly display them on screen.
        ; TODO: THIS IS A LOT OF CODE FOR SOMETHING THAT SHOULD BE STATICALLY CALCULATED.
        ;       ADD A WAY TO DO THIS WITHOUT CALCULATION AS IT ADDS A LOT OF CODE!
        ; this returns malloc'd array of num+1 spacings to apply around each widget.
        ; must be free'd after reading it
        jsr     calculate_spacing

        ; display the options with spacing.
        ; loop from 0 .. num-1 displaying spacer+widget
        ; and finish with the last spacing

        mva     #$00, tmp1


        setax   fps_spacing
        jsr     _free

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

; hideously complex way of calculating even spacing between widgets!
calculate_spacing:
        lda     fps_num
        sta     tmp1            ; we need to multiply this by len shortly, so store it
        clc
        adc     #$01            ; num+1 bytes required for spacing
        jsr     _malloc
        axinto  fps_spacing
        axinto  ptr4            ; need to index into it, so store it in ZP

        mva     #$01, ptr3      ; ptr3 is even/odd indicator, start with odd

        ; calculate the amount of extra space available around widgets
        mva     fps_len, tmp2   ; tmp1 = num, tmp2 = len
        jsr     fn_mul          ; tmp3/4 = num*len, can't actually be over 256, as there's only up to 36 width in total
        lda     fps_width
        sec
        sbc     tmp3            ; (width - num*len) = extra space in A. 1 byte only
        sta     tmp3            ; store extra space in tmp3

        ; calculate number of rounds needed to calculate spaces.
        ; for even num, it's num/2 - 1, for odd, it's num/2
        lda     fps_num
        lsr     a
        sta     tmp4
        bcs     odd
        dec     tmp4
        dec     ptr3            ; ptr3 = 0 means we're even
        ; round (r) = 0 .. tmp4
odd:
        mva     #$00, ptr1      ; use ptr1 as the round number (r), ptr1+1 as num-r
        ; this round's space = extra / (num + 1 - r)
        ; that is stored at spacing[r] and spacing[num-r]

        ; this calculation only needed once, then inc/dec them directly
        ; ptr1 = num + 1 - r, ptr1+1 = num - r
        lda     fps_num
        sec
        sbc     ptr1
        sta     ptr1+1          ; store (num-r)
        clc
        adc     #$01
        sta     tmp2            ; d  (num+1-r)

l_r:
        mva     tmp3, tmp1      ; q  (extra)
        jsr     fn_div             ; tmp1 = q/d, tmp2 = remainder

        ldy     ptr1
        lda     tmp1
        sta     (ptr4), y       ; store calculated space in spacing[r]
        ldy     ptr1+1
        sta     (ptr4), y       ; ... and spacing[num-r]

        ; extra = extra - A*2, A is the space calculated for 2 widgets
        asl     a               ; removing space consumed for this widget (and it's pair) from total available
        sta     tmp1
        lda     tmp3            ; extra
        sec
        sbc     tmp1            ; subtract space * 2
        sta     tmp3            ; set amount left

        ; save need to recalculate num+1-r
        dec     ptr1+1          ; num+1-r decreases by 1
        lda     ptr1+1
        sta     tmp2            ; store in tmp2 ready for division on next loop

        inc     ptr1            ; r = r + 1
        lda     ptr1

        ; loop over all r
        cmp     tmp4
        beq     l_r
        bcc     l_r

        ; for the even case, we have to store the final extra in next r (ptr1)
        lda     ptr3            ; 0 = even, 1 = odd
        bne     was_odd
        ldy     ptr1
        lda     tmp3
        sta     (ptr4), y       ; save final extra space in "middle" space, as there were an even number of widgets
        rts

was_odd:
        ; if there's any extra left over, add it to spacing[0]
        lda     tmp3            ; extra space
        beq     :+

        clc
        ldy     #$00
        adc     (ptr4), y
        sta     (ptr4), y
:
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
fps_spacing:    .res 2
