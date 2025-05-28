        .export     _edit_string
        .export     _es_params
        .export     _edit_string_buff
        .export     cmp_cursor_length

        .import     cng_cputc
        .import     cng_gotoxy
        .import     _cputc
        .import     _gotoxy
        .import     _kb_get_c
        .import     _display_string_in_viewport
        .import     incax1
        .import     pusha
        .import     pushax
        .import     pushptr1
        .import     return0
        .import     return1
        ; .import     _strlen
        .import     _fc_strlen
        .import     _memcpy
        .import     _memmove

        .include    "macros.inc"
        .include    "zp.inc"
        .include    "edit_string.inc"
        .include    "fn_data.inc"

.segment "CODE2"

; Advance cursor if not at max-1, preserves A/X
; Returns to caller if can't advance, falls through if can
advance_cursor_check:
        ; Calculate max_length-1 first
        lda     _es_params+edit_string_params::max_length
        sec                     ; Set carry for subtraction
        sbc     #1                  ; Subtract 1
        sta     tmp1                ; Store low byte
        lda     _es_params+edit_string_params::max_length+1
        sbc     #0                  ; Subtract carry from high byte
        sta     tmp2                ; Store high byte

        ; Compare cursor_pos with (max_length-1)
        lda     _es_params+edit_string_params::cursor_pos
        cmp     tmp1                ; Compare low bytes
        lda     _es_params+edit_string_params::cursor_pos+1
        sbc     tmp2                ; Compare high bytes with carry
        bcs     @done              ; If cursor_pos >= (max_length-1), don't advance

        ; Safe to increment cursor
        inc     _es_params+edit_string_params::cursor_pos
        bne     @done
        inc     _es_params+edit_string_params::cursor_pos+1

@done:
        jmp     display            ; Always go to display


; Helper function to show string at current position
; Input: A/X = length to show (16-bit)
show_string:
        ; Save length parameter to BSS
        sta     tmp2
        stx     tmp3

        ; Set cursor position
        pusha   _es_params+edit_string_params::x_loc
        lda     _es_params+edit_string_params::y_loc
        jsr     cng_gotoxy

        ; Initialize counter = tmp1, not trashed by cputc
        lda     #0
        sta     tmp1

        ; Load string pointer to zero page for indexed access
        ; Note: ptr1 is not affected by cputc, hence safe to do it once
        lda     _es_params+edit_string_params::initial_str
        sta     ptr1
        lda     _es_params+edit_string_params::initial_str+1
        sta     ptr1+1

@loop:
        lda     tmp1
        cmp     _es_params+edit_string_params::viewport_width  ; 1 byte only
        bcs     @done        ; if i >= viewport_width, done

        ; Compare counter with length (16-bit)
        ; lda     tmp1   ; already in A
        cmp     tmp2  ; Compare low bytes
        lda     #0          ; High byte of counter is always 0
        sbc     tmp3
        bcs     @print_space ; if counter >= length, print space

        ldy     tmp1
        lda     (ptr1),y    ; Load character
        jsr     cng_cputc
        clc
        bcc     @next

@print_space:
        lda     #' '
        jsr     cng_cputc

@next:
        inc     tmp1
        bne     @loop

@done:
        rts

;
; Common routines for 16-bit operations
;

; Compare cursor_pos with max_length (16-bit)
; Returns with carry set if cursor_pos >= max_length
cmp_cursor_max:
        lda     _es_params+edit_string_params::cursor_pos
        cmp     _es_params+edit_string_params::max_length
        lda     _es_params+edit_string_params::cursor_pos+1
        sbc     _es_params+edit_string_params::max_length+1
        rts

; Compare cursor_pos with current_length (16-bit)
; Returns with carry set if cursor_pos >= current_length
cmp_cursor_length:
        lda     _es_params+edit_string_params::cursor_pos
        cmp     _es_params+edit_string_params::current_length
        lda     _es_params+edit_string_params::cursor_pos+1
        sbc     _es_params+edit_string_params::current_length+1
        rts

; Compare current_length with max_length (16-bit)
; Returns with carry set if current_length >= max_length
cmp_length_max:
        lda     _es_params+edit_string_params::current_length
        cmp     _es_params+edit_string_params::max_length
        lda     _es_params+edit_string_params::current_length+1
        sbc     _es_params+edit_string_params::max_length+1
        rts

; Decrement cursor_pos (16-bit)
dec_cursor:
        lda     _es_params+edit_string_params::cursor_pos
        bne     @no_borrow
        dec     _es_params+edit_string_params::cursor_pos+1
@no_borrow:
        dec     _es_params+edit_string_params::cursor_pos
        rts

; Decrement current_length (16-bit)
dec_length:
        lda     _es_params+edit_string_params::current_length
        bne     @no_borrow
        dec     _es_params+edit_string_params::current_length+1
@no_borrow:
        dec     _es_params+edit_string_params::current_length
        rts

; Calculate buffer + cursor_pos into ptr1
calc_buffer_pos:
        lda     _es_params+edit_string_params::buffer
        clc
        adc     _es_params+edit_string_params::cursor_pos
        sta     ptr1
        lda     _es_params+edit_string_params::buffer+1
        adc     _es_params+edit_string_params::cursor_pos+1
        sta     ptr1+1
        rts

; Increment current_length (16-bit)
inc_length:
        inc     _es_params+edit_string_params::current_length
        bne     @done
        inc     _es_params+edit_string_params::current_length+1
@done:  rts

; Main edit_string function
_edit_string:
        ; Save original length
        setax   _es_params+edit_string_params::initial_str
        jsr     _fc_strlen
        axinto  orig_length

        ; Set up buffer pointer
        lda     #<_edit_string_buff
        sta     _es_params+edit_string_params::buffer
        lda     #>_edit_string_buff
        sta     _es_params+edit_string_params::buffer+1

        ; Copy initial string to buffer
        lda     _es_params+edit_string_params::buffer
        ldx     _es_params+edit_string_params::buffer+1
        jsr     pushax      ; Push destination

        lda     _es_params+edit_string_params::initial_str
        ldx     _es_params+edit_string_params::initial_str+1
        jsr     pushax      ; Push source

        setax   orig_length
        jsr     _memcpy

        ; Set current length and cursor position
        lda     orig_length
        sta     _es_params+edit_string_params::current_length
        sta     _es_params+edit_string_params::cursor_pos
        lda     orig_length+1
        sta     _es_params+edit_string_params::current_length+1
        sta     _es_params+edit_string_params::cursor_pos+1

        ; Check if cursor_pos needs adjustment
        jsr     cmp_cursor_max
        bcc     no_adjust

        jsr     dec_cursor

no_adjust:
        ; Display initial string
        jsr     _display_string_in_viewport

main_loop:
        jsr     _kb_get_c
        sta     char_input  ; Save character

        ; Check for zero (no input)
        beq     main_loop

        ; Special keys
        cmp     #FNK_ENTER
        bne     :+
        jmp     handle_enter
:
        cmp     #FNK_ESC
        bne     :+
        jmp     handle_escape
:
        cmp     #FNK_LEFT
        bne     :+
        jmp     handle_left
:
        cmp     #FNK_RIGHT
        bne     :+
        jmp     handle_right
:
        cmp     #FNK_DEL
        bne     :+
        jmp     handle_delete
:
        cmp     #FNK_BS
        bne     :+
        jmp     handle_backspace
:
        cmp     #FNK_INS
        bne     :+
        jmp     handle_insert
:
        cmp     #FNK_KILL
        bne     :+
        jmp     handle_kill
:
        cmp     #FNK_HOME
        bne     :+
        jmp     handle_home
:
        cmp     #FNK_END
        bne     check_ascii
        jmp     handle_end

check_ascii:
        ; Check for regular ASCII input
        cmp     #FNK_ASCIIL
        bcc     main_loop    ; If less than ASCIIL, ignore
        cmp     #FNK_ASCIIH+1
        bcs     main_loop    ; If greater than ASCIIH, ignore

        ; Check if number only mode
        lda     _es_params+edit_string_params::is_number
        beq     handle_char  ; If not number mode, accept any char

        lda     char_input
        cmp     #'0'
        bcc     main_loop    ; If less than '0', ignore
        cmp     #'9'+1
        bcs     main_loop    ; If greater than '9', ignore
        ; Otherwise handle valid number

handle_char:
        ; Load buffer pointer to zero page for indexed access
        ; do this early as it's used in multiple places
        lda     _es_params+edit_string_params::buffer
        sta     ptr1
        lda     _es_params+edit_string_params::buffer+1
        sta     ptr1+1

        ; Check if we can insert (16-bit compare)
        jsr     cmp_length_max
        bcs     check_replace

        ; Insert character at cursor position
        ldy     _es_params+edit_string_params::cursor_pos
        lda     char_input
        sta     (ptr1),y

        ; Update length if at end
        jsr     cmp_cursor_length
        bne     advance_cursor

        jsr     inc_length

        ; Add null terminator
        ldy     _es_params+edit_string_params::current_length
        lda     #0
        sta     (ptr1),y

advance_cursor:
        jmp     advance_cursor_check    ; this then jumps to "display"

check_replace:
        ; TODO: check the optimised code which skipped doing
        ; if (es_params.current_length == es_params.max_length)
        ; At max length, just replace character
        ldy     _es_params+edit_string_params::cursor_pos
        lda     char_input
        sta     (ptr1),y

        jmp     advance_cursor_check    ; this then jumps to "display"

handle_enter:
        ; Copy buffer back to initial string
        lda     _es_params+edit_string_params::initial_str
        ldx     _es_params+edit_string_params::initial_str+1
        jsr     pushax      ; Push destination

        lda     _es_params+edit_string_params::buffer
        ldx     _es_params+edit_string_params::buffer+1
        jsr     pushax      ; Push source

        lda     _es_params+edit_string_params::current_length
        ldx     _es_params+edit_string_params::current_length+1
        jsr     _memcpy

        ; Load initial string pointer to zero page for indexed access
        lda     _es_params+edit_string_params::initial_str
        sta     ptr1
        lda     _es_params+edit_string_params::initial_str+1
        sta     ptr1+1

        ; Add null terminator
        ldy     _es_params+edit_string_params::current_length
        lda     #0
        sta     (ptr1),y

        ; Show final string
        lda     _es_params+edit_string_params::current_length
        ldx     _es_params+edit_string_params::current_length+1
        jsr     show_string

        jmp     return1 ; return true

handle_escape:
        ; Show original string
        lda     orig_length     ; Original length low byte
        ldx     orig_length+1   ; Original length high byte
        jsr     show_string

        jmp     return0 ; return false

handle_left:
        ; Move cursor left if > 0 (16-bit compare)
        lda     _es_params+edit_string_params::cursor_pos
        ora     _es_params+edit_string_params::cursor_pos+1
        bne     :+
        jmp     display

:       jsr     dec_cursor
        jmp     display

handle_right:
        ; First calculate current_length - 1
        lda     _es_params+edit_string_params::current_length
        sec
        sbc     #1
        sta     tmp1        ; Store (current_length-1) low byte
        lda     _es_params+edit_string_params::current_length+1
        sbc     #0
        sta     tmp2        ; Store (current_length-1) high byte

        ; First condition: cursor_pos < (current_length - 1)
        lda     _es_params+edit_string_params::cursor_pos
        cmp     tmp1
        lda     _es_params+edit_string_params::cursor_pos+1
        sbc     tmp2
        bcc     can_move    ; If cursor_pos < (current_length-1), we can move

        ; If we get here, first condition failed
        ; Check second condition: cursor_pos == (current_length-1)
        lda     _es_params+edit_string_params::cursor_pos
        cmp     tmp1
        bne     check_done
        lda     _es_params+edit_string_params::cursor_pos+1
        cmp     tmp2
        bne     check_done

        ; cursor_pos == (current_length-1), now check current_length < max_length
        jsr     cmp_length_max
        bcs     check_done  ; If current_length >= max_length, can't move

can_move:
        ; Safe to move right
        inc     _es_params+edit_string_params::cursor_pos
        bne     no_carry5
        inc     _es_params+edit_string_params::cursor_pos+1
no_carry5:

check_done:
        jmp     display

handle_delete:
        ; Check if at end (16-bit compare)
        jsr     cmp_cursor_length
        bcc     common_move_left
        jmp     display

common_move_left:
        jsr     calc_buffer_pos
        jsr     pushptr1    ; dst
        jsr     incax1      ; add 1 to a/x, which are on ptr1
        jsr     pushax      ; src = dst + 1

        lda     _es_params+edit_string_params::current_length
        sec
        sbc     _es_params+edit_string_params::cursor_pos
        tay
        lda     _es_params+edit_string_params::current_length+1
        sbc     _es_params+edit_string_params::cursor_pos+1
        tax
        tya
        jsr     _memmove

        jsr     dec_length
        jmp     display

handle_backspace:
        ; Check if at start (16-bit compare)
        lda     _es_params+edit_string_params::cursor_pos
        ora     _es_params+edit_string_params::cursor_pos+1
        bne     :+
        jmp     display

:       jsr     dec_cursor
        jmp     common_move_left

handle_insert:
        ; Check first condition: cursor_pos < current_length
        jsr     cmp_cursor_length
        bcc     :+
        jmp     display          ; If cursor_pos >= current_length, done

        ; First condition true, setup common pointer
:       jsr     calc_buffer_pos
        setax   ptr1
        axinto  src_ptr     ; save the src for after memmove
        jsr     incax1
        jsr     pushax      ; dst = src+1
        jsr     pushptr1    ; src

        ; Check second condition: current_length < max_length
        jsr     cmp_length_max
        bcs     use_max_length  ; If current_length >= max_length, use max_length case

        ; Both conditions true: use current_length - cursor_pos + 1
        lda     _es_params+edit_string_params::current_length
        sec
        sbc     _es_params+edit_string_params::cursor_pos
        sta     tmp1            ; Store low byte of difference
        lda     _es_params+edit_string_params::current_length+1
        sbc     _es_params+edit_string_params::cursor_pos+1
        sta     tmp2            ; Store high byte of difference

        ; Add 1 to the 16-bit result
        lda     tmp1
        clc
        adc     #1              ; Add 1 to length for null terminator
        tay                     ; Low byte to Y for memmove
        lda     tmp2
        adc     #0              ; Add carry to high byte
        tax                     ; High byte to X for memmove
        tya                     ; Low byte to A for memmove
        jsr     _memmove

        ; Increment length (16-bit)
        jsr     inc_length
        jmp     insert_space

use_max_length:
        ; Only first condition true: use max_length - cursor_pos - 1
        ; First do max_length - cursor_pos
        lda     _es_params+edit_string_params::max_length
        sec
        sbc     _es_params+edit_string_params::cursor_pos
        sta     tmp1            ; Store low byte result
        lda     _es_params+edit_string_params::max_length+1
        sbc     _es_params+edit_string_params::cursor_pos+1
        sta     tmp2            ; Store high byte result

        ; Now subtract 1 from the 16-bit result
        lda     tmp1
        sec
        sbc     #1
        tay                 ; Low byte to Y for memmove
        lda     tmp2
        sbc     #0             ; Subtract carry from high byte
        tax                ; High byte to X for memmove
        tya                ; Low byte to A for memmove
        jsr     _memmove

insert_space:
        ; Common code to insert space at cursor position
        lda     src_ptr
        sta     ptr1
        lda     src_ptr+1
        sta     ptr1+1
        ldy     #$00
        lda     #' '
        sta     (ptr1),y

        jmp     display

handle_kill:
        ; Load buffer pointer to zero page for indexed access
        lda     _es_params+edit_string_params::buffer
        sta     ptr1
        lda     _es_params+edit_string_params::buffer+1
        sta     ptr1+1

        ; Truncate at cursor
        ldy     _es_params+edit_string_params::cursor_pos
        lda     #0
        sta     (ptr1),y

        ; Set current length to cursor position (16-bit)
        lda     _es_params+edit_string_params::cursor_pos
        sta     _es_params+edit_string_params::current_length
        lda     _es_params+edit_string_params::cursor_pos+1
        sta     _es_params+edit_string_params::current_length+1
        jmp     display

handle_home:
        ; Move cursor to start (16-bit)
        lda     #$00
        sta     _es_params+edit_string_params::cursor_pos
        sta     _es_params+edit_string_params::cursor_pos+1
        beq     display

handle_end:
        ; Move cursor to end (16-bit)
        lda     _es_params+edit_string_params::current_length
        sta     _es_params+edit_string_params::cursor_pos
        lda     _es_params+edit_string_params::current_length+1
        sta     _es_params+edit_string_params::cursor_pos+1

        ; Check if cursor_pos == max_length (16-bit compare)
        jsr     cmp_cursor_max
        bne     display
        ; If equal, decrement cursor_pos
        jsr     dec_cursor

display:
        jsr     _display_string_in_viewport
        jmp     main_loop


; allocate 256 byte buffer in BANK segment
.segment "BANK"
_edit_string_buff: .res 256

.bss
_es_params:     .tag edit_string_params

; Local storage for values that need to persist across function calls
orig_length:    .res 2  ; 16-bit original length
char_input:     .res 1  ; Input character
src_ptr:        .res 2  ; Source pointer for moves
