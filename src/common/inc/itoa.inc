.struct ITOA_PARAMS

    itoa_buf        .res 3
    ; value to convert, must be under 100. Useful for time, date etc, and small values on screen.
    itoa_input      .res 1
    ; if 1 show a leading 0
    itoa_show0      .res 1

.endstruct
