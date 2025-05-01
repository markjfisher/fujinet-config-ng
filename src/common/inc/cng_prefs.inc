; The order of data should remain constant here, so we can extend it in future without breaking previous versions

.struct CNG_PREFS_DATA
    ; appkey information version, allows us to react to future upgrades
    version      .byte

    ; the colour index of the screen the user picked (0-F)
    colour       .byte

    ; the brightness of colour (0-F)
    brightness   .byte

    ; shade of background/border (0-F)
    shade        .byte

    ; bar connected colour (0-FF)
    bar_conn     .byte

    ; bar disconnected colour (0-FF)
    bar_disconn  .byte

    ; bar copy colour (0-FF)
    bar_copy     .byte

    ; animation delay (0-F)
    anim_delay   .byte

.endstruct