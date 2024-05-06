        .export ak_version
        .export ak_colour_idx

.segment "LOW_DATA"

; THE FOLLOWING DATA MUST BE KEPT SEQUENCIALLY FOR fuji_appkey_write

; appkey information version, allows us to react to future upgrades
ak_version:     .res 1
; the colour index of the screen the user picked
ak_colour_idx:  .res 1

; more data to go here
