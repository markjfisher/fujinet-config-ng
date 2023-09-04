        .export     _fn_edit

        .import     s_empty     ; the "<Empty>" string
        .import     popax, pushax, popa
        .import     _fn_strncpy
        .import     _fn_strlen
        .import     _kb_get_c
        .import     ascii_to_code
        .import     _malloc, _free
        .import     return0, return1

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; bool fn_edit(char* str, void *scr_loc, uint8_t max_len, bool show_empty)
;
; Edit a string up to 255 chars. Enter/ESC to finish editing
; Cursor movement supported, including:
;    INSERT, DELETE, BACKSPACE
;    c-a, c-e, c-k from terminal editing.
; It's the responsibility of the caller to ensure the cursor stays within bounds of screen by setting appropriate
; maxLen and screen pointer.
;
; Future versions will allow scrolling, and maxView width to fit long strings in small slots
;
; PARAMS:
; char *str         - pointer to string being edit
; void *scr         - pointer to first location of screen where string is displayed
; uint8_t maxLen    - max string size
; bool show_empty   - show <Empty> when exiting and string is empty (for ESC)
;
; RETURNS:
; 0 if no edit occurred, 1 if the string was changed

.proc _fn_edit
        ; pull out the params
        sta     fe_show_empty
        popa    fe_max_len      ; this includes the 0 at the end, so strlen should be 1 less. e.g. max = 4: ["abc",0] is ok, so strlen of 3 is ok. but strlen of 4 is too long
        popax   fe_screen_loc
        popax   fe_str

        ; check length, if it's >= fe_max_len, exit with 0
        jsr     _fn_strlen      ; returns strlen, or #$ff for bad string, so we can always just check >= fe_max_len
        cmp     fe_max_len
        bcs     err             ; string was too large (>= fe_max_len), see params above
        bcc     :+

err:
        jmp     return0
        ; implicit rts

:       ; record the initial length, and set that as cursor position
        sta     fe_buf_len
        sta     fe_crs_idx
        jsr     cap_cursor      ; ensure the cursor doesn't start beyond bounds if initial string is at maxlen already

        ; allocate memory for s_copy
        lda     #38
        ldx     #$00
        jsr     _malloc
        axinto  s_copy          ; save the location
        axinto  ptr1            ; and in ZP for using indirectly

        ; copy string into buffer
        pushax  ptr1            ; pointer to the memory location of buffer
        pushax  fe_str          ; ptr to original string
        lda     fe_max_len
        jsr     _fn_strncpy     ; this fills up to max with 0s if string is short (or no string at all)

        ; if current String is empty (0 in first byte), clear the Edit box in case it has filler text
        ldy     #$00
        lda     (ptr1), y
        bne     not_empty

        mwa     fe_screen_loc, ptr4
        jsr     clear_edit      ; leaves with Z=1
        beq     :+              ; skip the double set of ptr4

not_empty:
        ; initial cursor at end of string - cursor either 1 past, or on last character (if string is max size)
        mwa     fe_screen_loc, ptr4
:       ldy     fe_crs_idx
        lda     (ptr4), y
        eor     #$80
        sta     (ptr4), y

        mwa     ptr1, ptr3

        ; THESE 2 SHOULD BE CONSISTENT THROUGH ENTIRE ROUTINE
        ; ptr3 = s_copy
        ; ptr4 = fe_screen_loc

        ; GOING INTO EACH CASE, A = keycode, Y = cursor index

; --------------------------------------------------------------------------
; KEYBOARD HANDLING
keyboard_loop:
        jsr     _kb_get_c       ; put current key press in A (0 = no key)
        cmp     #$00
        beq     keyboard_loop

        ldy     fe_crs_idx      ; current cursor position

; --------------------------------------------------------------------------
; ESC
        cmp     #FNK_ESC
        bne     not_esc
        ; abandon edits, reshow original string at this position
        ; first clear screen of any potential editing that's longer than the original string
        jsr     clear_edit

        mwa     fe_str, ptr1
        ldy     #$00
        lda     (ptr1), y
        beq     esc_show_empty

        jsr     put_ptr1_s
        jsr     cleanup
        beq     esc_exit

        ; re-write empty if there's no string set in host, but only if told to by param
esc_show_empty:
        lda     fe_show_empty
        beq     :+
        mwa     #s_empty, ptr1
        jsr     put_ptr1_s
:       jsr     cleanup

esc_exit:
        ; return values should be 0 in A/X to show we did no edit
        jmp     return0

not_esc:

; --------------------------------------------------------------------------
; BACKSPACE
        cmp     #FNK_BS
        bne     not_bs
        ; allow if Y > 0, on entry Y is current index
        cpy     #$00
        beq     keyboard_loop

        ; This involves:
        ; 1. move everything forward of current edit point down 1 char in buffer and put 0 at end of buffer
        ; 2. show buffer in line
        ; 3. decrease y
        ; 4. invert screen byte at y to look like cursor

        ; move all bytes up to the end down a position
:       lda     (ptr3), y
        dey
        sta     (ptr3), y
        iny
        iny
        cpy     fe_max_len
        bne     :-

        ; put a zero at the end
        dey
        mva     #$00, {(ptr3), y}

        ; reduce edit index and buffer length
        dec     fe_crs_idx
        dec     fe_buf_len
        jsr     refresh_line
        jmp     keyboard_loop

not_bs:

; --------------------------------------------------------------------------
; DELETE
        cmp     #FNK_DEL
        bne     not_del

        ; check if cursor is not at the end first. if it is, nothing to do
        lda     fe_crs_idx
        cmp     fe_buf_len
        bcc     can_del
        jmp     keyboard_loop   ; can't delete as there is nothing ahead of us

can_del:
        ; move bytes forward of ourselves down a position
        iny
:       lda     (ptr3), y
        dey
        sta     (ptr3), y
        iny
        iny
        cpy     fe_max_len
        bne     :-

        ; put a zero at the end
        dey
        mva     #$00, {(ptr3), y}

        ; reduce sbuffer length
        dec     fe_buf_len
        jsr     refresh_line
        jmp     keyboard_loop

not_del:

; --------------------------------------------------------------------------
; INSERT
        cmp     #FNK_INS
        bne     not_insert

        ; check if cursor is at end, do nothing if it is
        lda     fe_crs_idx
        cmp     fe_buf_len
        bcc     can_ins
        jmp     keyboard_loop

can_ins:
        ; push everything forward 1 char, up to end of buffer.
        ; string is always terminated up to end of buffer with zeroes due to initial strncpy
        ; last char if there was one, drops off end if string too big.
        ; put space in current location
        ; set y = max_len - 2 (one off for null, one off for not going too far)
        ldy     fe_max_len
        dey
        dey

        ; TODO: instead of bouncing Y around, use 2 ptrX locations instead
:       lda     (ptr3), y       ; load char from end, push it forward one, down to current position
        iny
        sta     (ptr3), y
        dey
        dey
        bmi     :+              ; were we editing at position 0? TODO: will this break with long strings?
        cpy     fe_crs_idx
        bcs     :-

        ; put space at our current location, y is 1 less than cursor location at moment
:       iny
        mva     #' ', {(ptr3), y}

        ; put 0 at end to ensure string is always nul terminated
        ldy     fe_max_len
        dey
        mva     #$00, {(ptr3), y}

        ; increase buffer len if we can
        jsr     tmp1_as_len_min_2
        lda     fe_buf_len
        cmp     tmp1
        bcs     no_extra
        inc     fe_buf_len

no_extra:
        jsr     refresh_line
        jmp     keyboard_loop

not_insert:

; --------------------------------------------------------------------------
; LEFT CURSOR
        cmp     #FNK_LEFT
        bne     not_left

        ; if cursor already at 0, don't move
        lda     fe_crs_idx
        cmp     #$00
        beq     :+

        dec     fe_crs_idx
        jsr     refresh_line

:
        jmp     keyboard_loop

not_left:

; --------------------------------------------------------------------------
; RIGHT CURSOR
        cmp     #FNK_RIGHT
        bne     not_right

        ; if cursor already at max, don't move.
        jsr     tmp1_as_len_min_2
        lda     fe_crs_idx
        cmp     tmp1

        beq     :+
        ; also can't be longer than the current buffer length
        cmp     fe_buf_len
        bcs     :+

        ; allowed to move cursor as it isn't at the ends
        inc     fe_crs_idx

:       jsr     refresh_line
        jmp     keyboard_loop

not_right:

; --------------------------------------------------------------------------
; HOME
        cmp     #FNK_HOME
        bne     not_home

        ; set cursor to 0
        mva     #$00, fe_crs_idx
        jsr     refresh_line
        jmp     keyboard_loop

not_home:

; --------------------------------------------------------------------------
; END
        cmp     #FNK_END
        bne     not_end_key

        ; set cursor to buf len (end of editing buffer)
        mva     fe_buf_len, fe_crs_idx
        jsr     cap_cursor

        jsr     refresh_line
        jmp     keyboard_loop

not_end_key:

; --------------------------------------------------------------------------
; KILL
        cmp     #FNK_KILL ; kill text to end of buffer
        bne     not_kill

        lda     #$00
:       sta     (ptr3), y       ; current cursor position forward should become 0s
        iny
        cpy     fe_max_len
        bcc     :-

        jsr     refresh_line
        jmp     keyboard_loop

not_kill:

; --------------------------------------------------------------------------
; ATASCII CHAR (between FNK_ASCIIL and FNK_ASCIIH inclusive)
        cmp     #FNK_ASCIIL
        bcs     space_or_more
        bcc     not_ascii
space_or_more:
        cmp     #FNK_ASCIIH+1
        bcs     not_ascii
        sta     tmp1            ; save it while we check bounds

        ; check bounds, if current edit position is on last char, we can't add more
        ldx     fe_max_len
        dex
        stx     tmp2
        cpy     tmp2
        bcs     :+

        ; ok! save this char to current edit index (y)
        mva     tmp1, {(ptr3), y}

        ; did we extend the buffer, or overwrite a char?
        ; we are overwriting if y index is less than buf len
        cpy     fe_buf_len
        bcc     :+
        inc     fe_buf_len

        ; can we move cursor on? yes if not now at end
:       jsr     tmp1_as_len_min_2
        cpy     tmp1
        beq     :+

        ; allowed to move cursor
        inc     fe_crs_idx

:       jsr     refresh_line
        jmp     keyboard_loop

not_ascii:

; --------------------------------------------------------------------------
; ENTER
        cmp     #FNK_ENTER
        bne     not_eol

        ; invert the char at edit location to remove cursor
        lda     (ptr4), y
        eor     #$80            ; invert high bit only. This is actually always 1->0 as we don't allow inverted chars  
        sta     (ptr4), y

        ; sets ptr2 to start of string to copy, and tmp1 to leading trim offset, which we need to reduce the copy size by
        jsr     trim_whitespace

        ; ptr2 is now pointing to real start of string to copy
        ; save the buffer into the original string's memory
        pushax  fe_str
        pushax  ptr2
        lda     fe_max_len
        ; reduce it by any leading whitespace we found
        sec
        sbc     tmp1
        jsr     _fn_strncpy     ; trashes ptr3/4
        ; restore screen pointer for print routines
        mwa     fe_screen_loc, ptr4

        ; if string is empty, display empty message again
        mwa     fe_str, ptr3
        ldy     #$00
        lda     (ptr3), y
        bne     :+

        mwa     #s_empty, ptr1
        jsr     put_ptr1_s      ; exits with A = 0
        beq     end_enter

:       ; write ptr2 (which points to first non whitespace) string to screen
        jsr     clear_edit
        mwa     ptr2, ptr1
        jsr     put_ptr1_s

end_enter:
        ; mark that we made an edit, so caller must act appropriately.
        jsr     cleanup
        jmp     return1
        ; implicit rts

not_eol:
        ; not a char we recognised, go back for next char
        jmp     keyboard_loop


; -------------------------------------------------------------------
; supporting procedures
; -------------------------------------------------------------------

; write blanks to screen up to max len
clear_edit:
        lda     #$00    ; space = 0 on screen
        ldy     #$00
:       sta     (ptr4), y
        iny
        cpy     fe_max_len
        bne     :-
        rts

; write the string at ptr1 to screen location fe_screen_loc (ptr4)
; no bounds checking. copies until finds 0
put_ptr1_s:
        ldy     #$00
:       lda     (ptr1), y
        beq     :+

        jsr     ascii_to_code
        sta     (ptr4), y
        iny
        bne     :-
:
        rts

; show current editing string at screen location and show cursor
refresh_line:
        ; copy buffer to screen memory and deal with last char by blanking whole line out first
        jsr     clear_edit
        mwa     ptr3, ptr1
        jsr     put_ptr1_s

        ; load Y with current location index
        ldy     fe_crs_idx

        ; invert the screen location's char for cursor display, which handles cursor INSIDE a string
        ; this is visual only, and doesn't affect buffer
        lda     (ptr4), y
        ora     #$80
        sta     (ptr4), y
        rts

tmp1_as_len_min_2:
        ldx     fe_max_len
        dex
        dex
        stx     tmp1
        rts

; Removes Trailing whitespace in buffer by replacing with 0
; Sets ptr2 to first non-space from the start
; Sets tmp1 to the offset amount from start to first non-space (i.e. ptr3 - ptr2)
trim_whitespace:
        ; in case the entire string is empty, set ptr2 to ptr3
        mwa     ptr3, ptr2

        ; reset leading trim to 0
        mva     #$00, tmp1

        ; find first non zero char from the end
        ldy     fe_max_len
        dey

:       dey
        bmi     end_trimming            ; went past the end, so everything was 0's
        lda     (ptr3), y               ; is our current byte 0?
        beq     :-                      ; yes, so loop

        ; trim trailing whitespace
        ; y now points to non 0 value, is it space?
:       lda     (ptr3), y
        cmp     #' '
        bne     non_space1
        mva     #$00, {(ptr3), y}       ; overwrite space with a 0
        dey
        bpl     :-                      ; keep looping until y < 0

non_space1:
        ; we hit a non-space, or y is $ff (last dey after dealing with 0th char)
        cpy     #$ff
        beq     end_trimming            ; we only had spaces in the whole string, which were replaced with 0s, so nothing else to trim

        ; find first non whitespace from start
        ldy     #$00
:       lda     (ptr3), y
        cmp     #' '
        bne     non_space2              ; eventually will hit something non space as we found it above
        iny
        bne     :-      ; always

non_space2:
        ; y points to a non-space from front.
        ; we can copy from here into target string
        mwa     ptr3, ptr2              ; do adjustment in ptr2 so it doesn't trash ptr3 for main routine
        tya
        sty     tmp1
        beq     end_trimming            ; nothing to add

        ; add offest to ptr2
        clc
        adc     ptr2
        sta     ptr2
        bcc     end_trimming
        inc     ptr2+1

end_trimming:
        rts

cap_cursor:
        ; if we're at max-1, put us at max-2 as can't move cursor into last byte
        ldx     fe_max_len
        dex
        cpx     fe_crs_idx
        bne     :+
        dex
        stx     fe_crs_idx

:       rts

cleanup:
        ; FREE s_copy
        setax   s_copy
        jsr     _free
        ; set A=0 so our callers can beq away
        lda     #$00
        rts

.endproc

.bss
fe_show_empty:  .res 1  ; bool to show empty or leave blank when ESC hit
fe_max_len:     .res 1  ; max length of string being edit. includes 0 char for end of string
fe_screen_loc:  .res 2  ; pointer to screen location to print to
fe_str:         .res 2  ; pointer to original string location being edit

fe_buf_len:     .res 1  ; buffer length, keep track as we make edits so don't have to redo strlen
fe_crs_idx:     .res 1  ; the index in the string of cursor position

s_copy:         .res 2  ; pointer to malloc'd data
