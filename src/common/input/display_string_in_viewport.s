        .export     _display_string_in_viewport

        .import     _gotoxy
        .import     _cputc
        .import     _revers
        .import     pusha
        .import     _es_params
        .import     cmp_cursor_length

        .include    "edit_string_asm.inc"
        .include    "macros.inc"
        .include    "zp.inc"

.segment "BSS"
start_pos:       .res 2  ; 16-bit start position for viewport
half_viewport:   .res 1  ; 8-bit half of viewport width
char_index:      .res 2  ; 16-bit character index

.segment "CODE2"

; void display_string_in_viewport()
_display_string_in_viewport:
        ; Calculate half_viewport = viewport_width / 2
        lda     _es_params+edit_string_params::viewport_width
        lsr     a               ; Divide by 2
        sta     half_viewport

        ; Initialize start_pos = 0
        lda     #0
        sta     start_pos
        sta     start_pos+1

        ; First check: cursor_pos > half_viewport
        lda     _es_params+edit_string_params::cursor_pos+1
        bne     @check_length   ; If high byte non-zero, definitely greater
        lda     _es_params+edit_string_params::cursor_pos
        cmp     half_viewport
        beq     @set_position   ; If equal, not greater
        bcc     @set_position   ; If less, not greater

@check_length:
        ; Second check: current_length >= viewport_width
        lda     _es_params+edit_string_params::current_length
        cmp     _es_params+edit_string_params::viewport_width
        lda     _es_params+edit_string_params::current_length+1
        sbc     #0              ; viewport_width is 8-bit
        bcs     :+
        jmp     @set_position   ; If current_length < viewport_width, skip adjustment

        ; Both conditions true, calculate start_pos = cursor_pos - half_viewport
:       lda     _es_params+edit_string_params::cursor_pos
        sec
        sbc     half_viewport
        sta     start_pos
        lda     _es_params+edit_string_params::cursor_pos+1
        sbc     #0
        sta     start_pos+1

        ; Check if cursor_pos >= current_length
        jsr     cmp_cursor_length
        bcc     @check_overflow

        ; cursor_pos >= current_length case:
        ; start_pos = current_length - viewport_width + 1
        lda     _es_params+edit_string_params::current_length
        sec
        sbc     _es_params+edit_string_params::viewport_width
        sta     start_pos
        lda     _es_params+edit_string_params::current_length+1
        sbc     #0              ; Complete the 16-bit subtraction
        sta     start_pos+1
        ; Now add 1 to the complete 16-bit result
        clc
        lda     start_pos
        adc     #1
        sta     start_pos
        lda     start_pos+1
        adc     #0
        sta     start_pos+1
        jmp     @set_position

@check_overflow:
        ; Calculate tmp1/2 = start_pos + viewport_width
        lda     start_pos
        clc
        adc     _es_params+edit_string_params::viewport_width
        sta     tmp1
        lda     start_pos+1
        adc     #0              ; Add carry to high byte
        sta     tmp2

        ; Compare tmp1/2 with current_length (16-bit)
        lda     tmp1
        cmp     _es_params+edit_string_params::current_length
        lda     tmp2
        sbc     _es_params+edit_string_params::current_length+1
        bcc     @set_position   ; If not greater, keep current start_pos

        ; start_pos + viewport_width > current_length case:
        ; start_pos = current_length - viewport_width
        lda     _es_params+edit_string_params::current_length
        sec
        sbc     _es_params+edit_string_params::viewport_width
        sta     start_pos
        lda     _es_params+edit_string_params::current_length+1
        sbc     #0
        sta     start_pos+1

@set_position:
        ; gotoxy(es_params.x_loc, es_params.y_loc)
        pusha   _es_params+edit_string_params::x_loc
        lda     _es_params+edit_string_params::y_loc
        ldx     #0
        jsr     _gotoxy

        ; Initialize char_index = start_pos
        lda     start_pos
        sta     char_index
        lda     start_pos+1
        sta     char_index+1

        ; for (i = 0; i < viewport_width; i++)
        lda     #0              ; i = 0
        sta     tmp1            ; Use tmp1 as our loop counter

@loop:
        ; Check if char_index == cursor_pos
        lda     char_index
        cmp     _es_params+edit_string_params::cursor_pos
        bne     @not_cursor
        lda     char_index+1
        cmp     _es_params+edit_string_params::cursor_pos+1
        bne     @not_cursor
        
        ; Set reverse mode
        lda     #1
        jsr     _revers

@not_cursor:
        ; Check if char_index < current_length
        lda     char_index
        cmp     _es_params+edit_string_params::current_length
        lda     char_index+1
        sbc     _es_params+edit_string_params::current_length+1
        bcs     @print_space

        ; Check if password mode
        lda     _es_params+edit_string_params::is_password
        bne     @print_star

        ; Set up buffer pointer in zero page
        lda     _es_params+edit_string_params::buffer
        sta     ptr1
        lda     _es_params+edit_string_params::buffer+1
        sta     ptr1+1

        ; Print character from buffer
        ldy     char_index      ; Use Y for indexing
        lda     (ptr1),y
        jsr     _cputc
        jmp     @check_cursor_after

@print_star:
        lda     #'*'
        jsr     _cputc
        jmp     @check_cursor_after

@print_space:
        lda     #' '
        jsr     _cputc

@check_cursor_after:
        ; Check if we need to turn off reverse mode
        lda     char_index
        cmp     _es_params+edit_string_params::cursor_pos
        bne     @next
        lda     char_index+1
        cmp     _es_params+edit_string_params::cursor_pos+1
        bne     @next
        
        ; Turn off reverse mode
        lda     #0
        jsr     _revers

@next:
        ; Increment char_index
        inc     char_index
        bne     :+
        inc     char_index+1
:
        ; Loop control
        inc     tmp1            ; i++
        lda     tmp1
        cmp     _es_params+edit_string_params::viewport_width
        bcc     @loop

        rts
