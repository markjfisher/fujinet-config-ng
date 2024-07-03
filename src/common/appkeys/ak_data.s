        .export _ak_version
        .export _ak_colour_idx

.segment "LOW_DATA"

; appkey information version, allows us to react to future upgrades
_ak_version:    .res 1
; the colour index of the screen the user picked
_ak_colour_idx: .res 1

; more data to go here
