        .export     _dev_edit_hosts_entry, sl_buffer, edit_pos_index ; last 2 for debug in altirra, they are exposed as values

        .import     fn_io_hostslots, host_selected, _fn_put_s, _fn_input, host_selected, _fn_io_put_host_slots
        .import     _fn_get_scrloc, pushax, _fn_strncpy, s_empty

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"

; int dev_edit_entry()
;
; user input in current 
.proc _dev_edit_hosts_entry
        ; get screen location for current edit position
        ldx     #(SL_X + SL_DX)
        lda     host_selected
        clc
        adc     #SL_Y
        sta     sl_y_coord
        tay
        jsr     _fn_get_scrloc  ; ptr4 set to screen location
        mwa     ptr4, start_of_edit_loc

        ; get pointer to the string for this host slot
        mwa     #fn_io_hostslots, ptr1
        ldx     host_selected
        beq     over_inc
:       adw     ptr1, #.sizeof(HostSlot)
        dex
        bne     :-

over_inc:
        ; ptr1 is location of current host entry, copy location for when we update it, or need to revert edit
        mwa     ptr1, host_loc_save
        ; copy the string to our buffer so we can revert changes if ESC hit
        pushax  #sl_buffer
        pushax  ptr1
        lda     #.sizeof(HostSlot)
        jsr     _fn_strncpy

        ; switch to using the buffer for our work
        mwa     #sl_buffer, ptr1

        ; if current host's name is empty string (0 in first byte), clear the Edit box, which currently says "<Empty>"
        ldy     #$00
        lda     (ptr1), y
        bne     not_empty

        ; write blanks over <Empty>
        put_s   {#(SL_X + SL_DX)}, sl_y_coord, #blank_field32

not_empty:
        ; add the string length for the current hostname
        ; advance until we hit 0 byte, or 31 chars (max host length + null)
        ldy     #$00
:       lda     (ptr1), y
        beq     stop_end_search
        cpy     #.sizeof(HostSlot)-1
        beq     stop_end_search
        iny
        bne     :-

stop_end_search:
        ; save the string length as the initial edit index
        sty     edit_pos_index
        ; also track the buffer's length for cursor movement
        sty     sl_buffer_len

        mwa     start_of_edit_loc, ptr4         ; restore screen location

        ; put a cursor in screen location. Y is initially length of current string, but tracks the cursor position
        ; further editing will INVERT the character at location, but htis first one is a straight $80 for inverse space
        mva     #$80, {(ptr4), y}

; --------------------------------------------------------------------------
; KEYBOARD HANDLING
l1:     jsr     _fn_input
        cmp     #$00
        beq     l1      ; could be clever and not do this, and flash cursor etc.

        ldy     edit_pos_index  ; reset Y to current edit location. it was trashed by system kb routine

; --------------------------------------------------------------------------
; ESC
        cmp     #ATESC
        bne     not_esc
        ; escape pressed, reshow current host at this position
        ; but first write 32 blanks to clear any editing
        put_s   {#(SL_X + SL_DX)}, sl_y_coord, #blank_field32

        ; re-write emtpy if there's no string set in host
        mwa     host_loc_save, ptr1
        ldy     #$00
        lda     (ptr1), y
        beq     esc_show_empty

        put_s   {#(SL_X + SL_DX)}, sl_y_coord, host_loc_save
        rts

esc_show_empty:
        put_s   {#(SL_X + SL_DX)}, sl_y_coord, #s_empty
        rts

not_esc:
; --------------------------------------------------------------------------
; BACKSPACE (RUBout)
        cmp     #ATRUB
        bne     not_bs
        ; allow if Y > 0, on entry Y is current index
        cpy     #$00
        beq     l1

        ; This involves:
        ; 1. move everything forward of current edit point down 1 char in buffer and put 0 at end of buffer
        ; 2. show sl_buffer in line
        ; 3. decrease y
        ; 4. invert screen byte at y to look like cursor

        ; move all bytes up to the end down a position
        mwa     #sl_buffer, ptr3
:       lda     (ptr3), y
        dey
        sta     (ptr3), y
        iny
        iny
        cpy     #.sizeof(HostSlot)
        bne     :-

        ; put a zero at the end
        dey
        lda     #$00
        sta     (ptr3), y

        ; reduce edit index and sl_buffer length
        dec     edit_pos_index
        dec     sl_buffer_len
        jsr     refresh_line

        jmp     l1

not_bs:
; --------------------------------------------------------------------------
; DELETE ($FE = ATDEL)
        cmp     #ATDEL
        bne     not_del

        ; check if cursor is not at the end first. if it is, nothing to do
        lda     edit_pos_index
        cmp     sl_buffer_len
        bcc     can_del
        jmp     l1              ; can't delete as there is nothing ahead of us

can_del:
        ; move bytes forward of ourselves down a position
        mwa     #sl_buffer, ptr3
        iny
:       lda     (ptr3), y
        dey
        sta     (ptr3), y
        iny
        iny
        cpy     #.sizeof(HostSlot)
        bne     :-

        ; put a zero at the end
        dey
        lda     #$00
        sta     (ptr3), y

        ; reduce sl_buffer length
        dec     sl_buffer_len
        jsr     refresh_line

        jmp     l1

not_del:

; --------------------------------------------------------------------------
; INSERT ($FF = ATINS)
        cmp     #ATINS
        bne     not_insert

        ; check if cursor is at end, do nothing if it is
        lda     edit_pos_index
        cmp     sl_buffer_len
        bcc     can_ins
        jmp     l1

can_ins:
        ; push everything forward 1 char, up to end of buffer.
        ; string is always terminated up to end of buffer with zeroes due to initial strncpy
        ; last char if there was one, drops off end if string too big.
        ; put space in current location
        mwa     #sl_buffer, ptr3
        ldy     #.sizeof(HostSlot)-2
        ; TODO: instead of bouncing Y around, use 2 ptrX locations instead
:       lda     (ptr3), y       ; load char from end, push it forward one, down to current position
        iny
        sta     (ptr3), y
        dey
        dey
        cpy     edit_pos_index
        bcs     :-

        ; put space at our current location, y is 1 less than cursor location at moment
        iny
        lda     #' '
        sta     (ptr3), y

        ; put 0 at end to ensure string is always nul terminated
        ldy     #.sizeof(HostSlot)-1
        lda     #$00
        sta     (ptr3), y

        ; increase buffer len if we can
        lda     sl_buffer_len
        cmp     #.sizeof(HostSlot)-2
        bcs     no_extra
        inc     sl_buffer_len

no_extra:

        jsr     refresh_line

        jmp     l1

not_insert:

; --------------------------------------------------------------------------
; LEFT CURSOR ($1E = ATLRW)
        cmp     #ATLRW
        bne     not_left_arrow

        ; if cursor already at 0, don't move
        lda     edit_pos_index
        cmp     #$00
        beq     :+

        dec     edit_pos_index
        jsr     refresh_line

:
        jmp     l1

not_left_arrow:

; --------------------------------------------------------------------------
; RIGHT CURSOR ($1F = ATRRW)
        cmp     #ATRRW
        bne     not_right_arrow

        ; if cursor already at max, don't move. -2 because we don't want cursor to run into border
        lda     edit_pos_index
        cmp     #.sizeof(HostSlot)-2
        beq     :+
        ; also can't be longer than the current sl_buffer_length
        cmp     sl_buffer_len
        bcs     :+

        ; allowed to move cursor as it isn't at the ends
        inc     edit_pos_index

:       jsr     refresh_line
        jmp     l1

not_right_arrow:
; --------------------------------------------------------------------------
; ATASCII CHAR (between $20 and $7D inclusive)
        cmp     #$20
        bcs     space_or_more
        bcc     not_ascii
space_or_more:
        cmp     #$7e
        bcs     not_ascii
        sta     tmp1            ; save it while we check bounds

        ; check bounds, if current edit position is on last char, we can't add more
        cpy     #.sizeof(HostSlot)-1
        bcs     :+

        ; ok! save this char to current edit index (y)
        mwa     #sl_buffer, ptr3
        mva     tmp1, {(ptr3), y}

        ; did we extend the buffer, or overwrite a char?
        ; we are overwriting if y index is less than buf len
        cpy     sl_buffer_len
        bcc     :+
        inc     sl_buffer_len

        ; can we move cursor on? yes if not now at end
:       cpy     #.sizeof(HostSlot)-2
        beq     :+

        ; allowed to move cursor, so we must have added a char too
        inc     edit_pos_index
        

:       jsr     refresh_line
        jmp     l1

not_ascii:

; --------------------------------------------------------------------------
; ENTER ($9B = ATEOL)
        cmp     #ATEOL
        bne     not_eol

        ; invert the char at edit location to remove cursor, ptr4 already at start of screen edit position
        lda     (ptr4), y
        eor     #$80            ; invert high bit only. This is actually always 1->0 as we don't allow inverted chars  
        sta     (ptr4), y

        jsr     trim_whitespace         ; sets ptr3 to start of string to copy, save it
        mwa     ptr3, sl_start_non_space

        ; sl_start_non_space is now pointing to real start of string to copy to
        ; save the buffer into the host memory
        pushax  host_loc_save
        pushax  sl_start_non_space
        lda     #.sizeof(HostSlot)
        ; reduce it by any leading whitespace we found
        sec
        sbc     sl_lead_trim_offset
        jsr     _fn_strncpy

        ; if string is empty, display empty message again
        mwa     host_loc_save, ptr4
        ldy     #$00
        lda     (ptr4), y
        bne     :+

        put_s   {#(SL_X + SL_DX)}, sl_y_coord, #s_empty
        jmp     do_hosts_save

:       ; write sl_start_non_space string to screen, to remove any trimming - PTR3 TRASHED
        put_s   {#(SL_X + SL_DX)}, sl_y_coord, #blank_field32
        put_s   {#(SL_X + SL_DX)}, sl_y_coord, sl_start_non_space

do_hosts_save:
        ; send hosts data to FN
        jmp     _fn_io_put_host_slots
        ; implicit rts, exiting editing mode

not_eol:
        ; not a char we recognised, go back for next char
        jmp     l1

; Redisplay the current line, and put cursor in it
refresh_line:
        ; copy sl_buffer to screen memory and deal with last char by blanking whole line out first - could be slightly more efficient here
        put_s   {#(SL_X + SL_DX)}, sl_y_coord, #blank_field32
        put_s   {#(SL_X + SL_DX)}, sl_y_coord, #sl_buffer

        ; load Y with current location index
        ldy     edit_pos_index

        ; invert the screen location's char for cursor display, which handles cursor INSIDE a string
        ; this is visual only, and doesn't affect buffer
        mwa     start_of_edit_loc, ptr4
        lda     (ptr4), y
        ora     #$80
        sta     (ptr4), y
        rts

trim_whitespace:
        ; reset leading trim to 0
        mva     #$00, sl_lead_trim_offset

        ; find first non zero char from the end
        mwa     #sl_buffer, ptr3
        ldy     #.sizeof(HostSlot)-1    ; this is always 0, so we can immediately skip it
:       dey
        cpy     #$ff
        beq     end_trimming            ; went past the end, so everything was 0's
        lda     (ptr3), y               ; is our current byte 0?
        beq     :-                      ; yes, so loop

        ; trim trailing whitespace
        ; y now points to non 0 value, is it space?
:       lda     (ptr3), y
        cmp     #' '
        bne     non_space1
        lda     #$00
        sta     (ptr3), y               ; overwrite space with a 0
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
        ; we can copy from here into hosts string

        tya
        sty     sl_lead_trim_offset
        beq     end_trimming            ; nothing to add

        ; add offest to ptr3
        clc
        adc     ptr3
        sta     ptr3
        bcc     end_trimming
        inc     ptr3+1

end_trimming:
        rts

.endproc

.segment "SDATA"
blank_field32: .byte "                                ", 0

.bss
edit_pos_index:         .res 1
sl_y_coord:             .res 1
host_loc_save:          .res 2
start_of_edit_loc:      .res 2
sl_buffer:              .tag HostSlot
sl_buffer_len:          .res 1
sl_lead_trim_offset:    .res 1
sl_start_non_space:     .res 2