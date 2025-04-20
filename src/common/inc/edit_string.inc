.struct edit_string_params
    initial_str     .word   ; pointer to initial string
    max_length      .word   ; maximum length allowed
    x_loc           .byte   ; x location on screen
    y_loc           .byte   ; y location on screen
    viewport_width  .byte   ; width of viewport
    is_password     .byte   ; boolean for password mode
    is_number       .byte   ; boolean for number-only mode
    buffer          .word   ; pointer to edit buffer
    current_length  .word   ; current length of string
    cursor_pos      .word   ; current cursor position
.endstruct
