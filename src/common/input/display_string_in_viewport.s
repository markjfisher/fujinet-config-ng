        .export     _display_string_in_viewport
        .export     start_pos
        .export     char_index
        .export     half_viewport

        .import     cng_cputc
        .import     cng_gotoxy
        .import     _cputc
        .import     _gotoxy
        .import     _revers
        .import     pusha
        .import     _es_params
        .import     cmp_cursor_length

        .include    "edit_string.inc"
        .include    "macros.inc"
        .include    "zp.inc"

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

        ; Check if cursor_pos > half_viewport and current_length >= viewport_width
        lda     _es_params+edit_string_params::cursor_pos+1
        bne     @check_length   ; If high byte non-zero, definitely greater

        lda     _es_params+edit_string_params::cursor_pos
        cmp     half_viewport
        beq     @set_position   ; If cursor_pos == half_viewport, skip adjustment
        bcc     @set_position   ; If cursor_pos < half_viewport, skip adjustment

@check_length:
        ; Second check: current_length >= viewport_width
        lda     _es_params+edit_string_params::current_length
        cmp     _es_params+edit_string_params::viewport_width
        lda     _es_params+edit_string_params::current_length+1
        sbc     #0              ; viewport_width is 8-bit
        bcc     @set_position   ; If current_length < viewport_width, skip adjustment

        ; Calculate start_pos = cursor_pos - half_viewport
        lda     _es_params+edit_string_params::cursor_pos      ; Load low byte of cursor_pos
        sec
        sbc     half_viewport                                  ; Subtract half_viewport
        sta     start_pos                                      ; Store low byte of start_pos

        lda     _es_params+edit_string_params::cursor_pos+1    ; Load high byte of cursor_pos
        sbc     #0                                             ; Subtract carry from high byte
        sta     start_pos+1                                    ; Store high byte of start_pos

        ; Check if start_pos + viewport_width > current_length
        clc
        lda     start_pos
        adc     _es_params+edit_string_params::viewport_width
        sta     tmp1
        lda     start_pos+1
        adc     #0
        sta     tmp2

        lda     tmp1
        cmp     _es_params+edit_string_params::current_length
        lda     tmp2
        sbc     _es_params+edit_string_params::current_length+1
        bcc     @check_cursor_pos

        ; Adjust start_pos to current_length - viewport_width
        lda     _es_params+edit_string_params::current_length
        sec
        sbc     _es_params+edit_string_params::viewport_width
        sta     start_pos
        lda     _es_params+edit_string_params::current_length+1
        sbc     #0
        sta     start_pos+1

@check_cursor_pos:
        ; If cursor_pos >= current_length, increment start_pos
        jsr     cmp_cursor_length
        bcs     @increment_start_pos
        jmp     @set_position

@increment_start_pos:
        inc     start_pos
        bne     @set_position
        inc     start_pos+1

@set_position:
        ; Finalize start_pos
        ; gotoxy(es_params.x_loc, es_params.y_loc)
        pusha   _es_params+edit_string_params::x_loc
        lda     _es_params+edit_string_params::y_loc
        jsr     cng_gotoxy

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
        jsr     cng_cputc
        jmp     @check_cursor_after

@print_star:
        lda     #'*'
        jsr     cng_cputc
        jmp     @check_cursor_after

@print_space:
        lda     #' '
        jsr     cng_cputc

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

.bss
start_pos:       .res 2  ; 16-bit start position for viewport
half_viewport:   .res 1  ; 8-bit half of viewport width
char_index:      .res 2  ; 16-bit character index
