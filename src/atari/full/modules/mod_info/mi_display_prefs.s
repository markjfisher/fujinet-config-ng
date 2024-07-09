        .export     _mi_display_prefs

        .include    "zp.inc"
        .include    "macros.inc"

.proc _mi_display_prefs
        ; show:
        ;  0: colour (0-F)
        ;  1: darkness/shade (0-F)
        ;  2: bar: conn, (0-FF)    default b4 (green)
        ;  3: bar: disconn (0-FF)  default 33 (red)
        ;  4: bar: copy (0-FF)     default 66 (blue)

        ; we will allow the bar to show on the 5 values, and then popup to edit each one.
        ; so we need a generic key/value showing, and then those in a popup with appropriate editor type and filter for keys (length and hex keys only)
        ; There isn't currently an "is_hex" on edit_string though.



        rts
.endproc